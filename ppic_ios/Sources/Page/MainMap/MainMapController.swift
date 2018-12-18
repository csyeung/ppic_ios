//
//  ViewController.swift
//  ppic
//
//  Created by Jonathan YEUNG on 2018/07/04.

//

import UIKit
import Mapbox
import RxSwift
import RxCocoa
import DIKit
import ClusterKit
import Kingfisher

final class MainMapController: BaseViewController, PropertyInjectable {
	struct Dependency {
		let mapStyleURL: URL?
        let defaultCellSize: CGFloat
        let defaultZoomLevel: Double
        let maxZoomLevel: Double
        let mapRefreshPeriod: Int
		let viewModel: MainMapViewModelProtocol
	}
	
    enum TargetPage : TransitionInformation {
        case recruit
        case message
        case profile(uid: String)
        case pickShow(id: String)
    }

	var dependency: Dependency!
	
    @IBOutlet weak var profileButtonView: UIImageView!
    @IBOutlet weak var dmButton: UIButton!
    @IBOutlet weak var recruitButton: PicButton!
    @IBOutlet weak var currentButton: UIButton!
    @IBOutlet weak var releaseButton: UIButton!

    private var mapStyleURL: URL?
    private(set) var mapView: MGLMapView!
    private let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
    private var defaultZoomLevel: Double?
    private var maxZoomLevel: Double?
    private let locationManager = CLLocationManager()
    
	private(set) var viewModel: MainMapViewModelProtocol!
    private let userUsecase = UserUsecase()
    
    // !!!: マップに関するデータ処理は暫定こういう形に実装して、後ほどDI形式に改修します
    private let mapDataUsecase = MapDataUsecase()
    private var picEntities = Variable([PicEntity]())
    
    // 距離更新について
    private(set) var lastCoordinate: CLLocationCoordinate2D?
    
    // 間隔的更新に関する設定
    private(set) var refreshPeriod: Int = 30
    private(set) var lastReload: Date = Date()
    private(set) var isUpdating: Bool = false
    
    // MyPic に関する設定
    private var myPic: PicAnnotation?
	private let disposeBag: DisposeBag = .init()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		injectDependencies()
        setupMapView()
		bindMapView()
        setupPicButton()
        setupProfileButton()
        setupTimerTask()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadData(zoomLevel: mapView.zoomLevel)
    }
}

// MARK: Main function
extension MainMapController {
	private func injectDependencies() {
		mapStyleURL = dependency.mapStyleURL
		viewModel = dependency.viewModel
        
        // アルゴリズムの設定
        algorithm.cellSize = dependency.defaultCellSize
        defaultZoomLevel = dependency.defaultZoomLevel
        maxZoomLevel = dependency.maxZoomLevel
        refreshPeriod = dependency.mapRefreshPeriod
	}
	
    private func setupMapView() {
		mapView = MGLMapView(frame: view.bounds, styleURL: mapStyleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.marginFactor = 1
        mapView.delegate = self

        if let maxZoom = maxZoomLevel {
            mapView.maximumZoomLevel = maxZoom
        }
        
        // User Location
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.showsUserLocation = true
        
        // コンパス
        mapView.compassView.isHidden = true
        
        //
		view.insertSubview(mapView, at: 0)
        
        // Location Manager 
        locationManager.delegate = self
    }
	
	private func bindMapView() {
		viewModel.centerAndZoomLevel
			.asDriver(onErrorDriveWith: Driver.empty())
			.drive(rx.mapCenterZoomBinder())
			.disposed(by: disposeBag)
        
        self.picEntities.asObservable().bind { [weak self] entities in
            guard let this = self else { return }
            if this.myPic != nil { return }
            
            DispatchQueue(label: "add pics annotations").async {
                var annotations = [PicAnnotation]()
                let currentAnnotations = this.mapView.clusterManager.annotations as! [MGLAnnotation]
                
                for entity in entities {
                    if currentAnnotations.contains(where: { obj -> Bool in
                        guard let myPic = obj as? PicAnnotation else {
                            return false
                        }
                        
                        return myPic.picEntity.id == entity.id
                    }) {
                        continue
                    }
                    
                    let annotation = PicAnnotation(entity)
                    annotation.coordinate = CLLocationCoordinate2DMake(entity.geo.latitude, entity.geo.longitude)
                    annotations.append(annotation)
                }
                
                DispatchQueue.main.async {
                    this.mapView.clusterManager.addAnnotations(annotations)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    private func setupTimerTask() {
        let scheduler = SerialDispatchQueueScheduler(qos: .background)
        let timer = Observable<Int>.timer(0, period: RxTimeInterval.init(exactly: 1), scheduler: scheduler).map{ _ in () }
        Observable.of(timer).merge().subscribe({ [unowned self] _ in
            if self.myPic != nil { return }
            let lastUpdate = self.lastReload.getInterval(toDate: Date(), component: Calendar.Component.second)
     
            if lastUpdate > self.refreshPeriod && !self.isUpdating {
                // 絵かきに関する操作はメインスレッドでやらない場合はクラッシュしてしまいました
                DispatchQueue.main.async {
                    self.clearAnnotation()
                    self.loadData(zoomLevel: self.mapView.zoomLevel)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func setupProfileButton() {
        // ImageView でタプ反応を対応
        let tapGesture = UITapGestureRecognizer()
        
        tapGesture.rx.event.bind { [weak self] sender in
            UIView.animate(withDuration: 0.2, animations: {
                self?.profileButtonView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { finished in
                self?.profileButtonView.transform = CGAffineTransform.identity
                self?.doRequestProfile()
            })
        }.disposed(by: disposeBag)
        
        self.profileButtonView.isUserInteractionEnabled = true
        self.profileButtonView.addGestureRecognizer(tapGesture)
        
        // 画像
        self.userUsecase.getMyProfile { [weak self] user in
            guard let url = URL(string: user.photoURL) else { return }
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { [weak self] image, error, cacheType, imageURL in
                self?.profileButtonView.clipsToBounds = true
                self?.profileButtonView.image = image
            })
        }
    }
    
    private func setupPicButton() {
        self.userUsecase.getMyProfile { [weak self] user in
            guard let this = self else { return }
            if let expiredAt = user.currentPic?.expiredAt {
                this.recruitButton.showCount()
                this.recruitButton.startCountdown(expiredAt: expiredAt)
            } else {
                this.recruitButton.showIcon()
            }
        }
    }
    
    private func loadData(zoomLevel: Double) {
        self.isUpdating = true
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        let leftTop = mapView.convert(CGPoint(x: 0, y: screenHeight / 4), toCoordinateFrom: nil)
        let rightTop = mapView.convert(CGPoint(x: screenWidth, y:screenHeight / 4), toCoordinateFrom: nil)
        let leftBottom = mapView.convert(CGPoint(x: 0, y: screenHeight), toCoordinateFrom: nil)
        let rightBottom = mapView.convert(CGPoint(x: screenWidth, y: screenHeight), toCoordinateFrom: nil)
        
        var current: CLLocationCoordinate2D!
        if let coordinate = mapView.userLocation?.coordinate {
            current = coordinate
        } else {
            current = mapView.convert(CGPoint(x: screenWidth / 2, y: screenHeight / 2), toCoordinateFrom: nil)
        }

        // 暫定対処
        self.mapDataUsecase.getMapInfos(lt: leftTop, rt: rightTop, rb: rightBottom, lb: leftBottom, current: current, zoomLevel: self.mapView.zoomLevel) { [weak self] entities in
            // 暫定履歴処理なし
            if let entities = entities {
                self?.picEntities.value = entities
            } else {
                self?.clearAnnotation()
                self?.picEntities.value.removeAll()
            }
            
            self?.lastReload = Date()
            self?.isUpdating = false
        }
    }
    
    private func getPicEntity(from annotation: MGLAnnotation) -> PicEntity? {
        if let cluster = annotation as? CKCluster, let marker = cluster.firstAnnotation as? PicAnnotation {
            return marker.picEntity
        }
        
        if let marker = annotation as? PicAnnotation {
            return marker.picEntity
        }
        
        return nil
    }
    
    // Pic をクリア
    private func clearAnnotation() {
        if let annotations = mapView.annotations {
            mapView.removeAnnotations(annotations)
        }
        
        mapView.clusterManager.removeAnnotations(mapView.clusterManager.annotations)
    }
    
    // MyPic の表示
    func setMyPic(pic: PicEntity, dynamicLink: String?) {
        self.clearAnnotation()
        self.picEntities.value.removeAll()
        
        // ぴっくを設置
        let myPic: PicAnnotation = .init(pic, isMyPic: true)
        mapView.addAnnotation(myPic)
        
        self.myPic = myPic
        
        // マップに移動
        let location = CLLocationCoordinate2DMake(pic.geo.latitude, pic.geo.longitude)
        mapView.setCenter(location, animated: true)
        
        // ボタン表示
        self.releaseButton.isHidden = false
        
        if let dynamicLink = dynamicLink {
            UIPasteboard.general.setValue(dynamicLink, forPasteboardType: "public.text")
            
            let title = ""
            let message = "リンクをコピーしました"
            
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            
            alert.addAction(defaultAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func updateMapViewOnLocationChange() {
        self.clearAnnotation()
        self.lastCoordinate = mapView.centerCoordinate
        self.loadData(zoomLevel: mapView.zoomLevel)
    }
}

private extension Reactive where Base: MainMapController {
	func mapCenterZoomBinder() -> Binder<(CLLocationCoordinate2D, Double)> {
		return .init(base, binding: { (base, value) in
			base.mapView.setCenter(value.0, zoomLevel: value.1, animated: false)
		})
	}
}

// MARK: Buttons
// テストのため：アルバム表示はマップで実装します
extension MainMapController {
    @IBAction func doRequestProfile() {
        let userRepository = UserRepository()
        
        // TODO: viewModel -> useCase を使う
        userRepository.findMine { (user) in
            self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.profile(uid: user.uid))
        }
    }
    
    @IBAction func doRecruit() {
        // TODO: 自分のpicと他人のpicとで遷移先が違う。Button自体を分けたほうが良い
        // TODO: 本来はViewModelのしごと?
        self.userUsecase.getMyProfile { user in
            if user.hasPic(){
                self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.pickShow(id: user.currentPic!.id))
                return
            }
            self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.recruit)
        }
    }
    
    @IBAction func doRequestChat() {
        transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.message)
    }
    
    @IBAction func showCurrentPosition() {
        mapView.setUserTrackingMode(.follow, animated: false)
        mapView.showsUserLocation = true
        mapView.zoomLevel = defaultZoomLevel!
    }
    
    @IBAction func clearMyPic() {
        guard let pic = self.myPic else { return }
        
        // myPic 表示解除
        mapView.removeAnnotation(pic)
        self.myPic = nil
        
        // ボタン表示解除
        self.releaseButton.isHidden = true
        
        // 現在地に戻る（できれば）
        if let location = mapView.userLocation?.coordinate {
            mapView.setCenter(location, animated: true)
        }
        
        loadData(zoomLevel: mapView.zoomLevel)
    }
}

// MARK: MGLMapViewDelegate
extension MainMapController : MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        guard let entity = getPicEntity(from: annotation) else {
            return
        }
        
        self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.pickShow(id: entity.id))
    }

    // viewFor
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if let cluster = annotation as? CKCluster {
            if let picAnnotation = cluster.firstAnnotation as? PicAnnotation {
                let view : PicAnnotationView = .init(picAnnotation.picEntity, isMyPic: picAnnotation.isMyPic)
                return view
            }            
        }
        
        if let picAnnotation = annotation as? PicAnnotation {
            let view : PicAnnotationView = .init(picAnnotation.picEntity, isMyPic: picAnnotation.isMyPic)
            return view
        }
        
        return nil
    }

    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.zoomLevel < 14 {
            self.clearAnnotation()
            self.lastCoordinate = nil
            return
        }
        
        if let lastCoord = self.lastCoordinate {
            let locationPrev = CLLocation(latitude: lastCoord.latitude, longitude: lastCoord.longitude)
            let locationCurr = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            
            let distance : CLLocationDistance = locationPrev.distance(from: locationCurr)
            
            // Pixel Resolutionを計算
            let pixelRes = AppUtility.makeWidthFromDistance(zoomLevel: mapView.zoomLevel, latitude: mapView.centerCoordinate.latitude)
            
            // 画面の幅の1/3を移動したら更新する
            let updateThreshold = fabs(pixelRes * Double(UIScreen.main.bounds.width) / 3)
            if !distance.isLess(than: updateThreshold) {
                print("Reload = \(updateThreshold)")
                self.updateMapViewOnLocationChange()
            }
        } else {
            self.updateMapViewOnLocationChange()
        }
        
        self.mapView.clusterManager.updateClustersIfNeeded()
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
}

// MARK: CLLocationManagerDelegate
extension MainMapController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .denied, .restricted:
            break
            
        case .authorizedAlways, .authorizedWhenInUse:
            guard let coordinate = manager.location?.coordinate else { return }
            self.mapView.setCenter(coordinate, animated: false)
        }
    }
}
