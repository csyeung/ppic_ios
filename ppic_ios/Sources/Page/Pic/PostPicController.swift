//
// Created by Jonathan YEUNG on 2018/07/10.
// ppic_ios

// 

import UIKit
import CoreLocation
import RxSwift
import DIKit
import SVProgressHUD

final class PostPicController : UIViewController, PropertyInjectable {
    struct Dependency {
        let keyboard : CGFloat
        let keyboardiPad : CGFloat
        let photoWidth : CGFloat
        let defaultPlace : CLLocationCoordinate2D
        let titleLimit : Int
    }
    
    @IBOutlet weak var postImage : UIImageView!
    @IBOutlet weak var closeButton : UIButton!
    @IBOutlet weak var photoButton : UIButton!
    @IBOutlet weak var recruitButton : UIButton!
    @IBOutlet weak var titleTextField : UITextField!
    @IBOutlet weak var photoButtonTopMargin : NSLayoutConstraint!
    
    var dependency: Dependency!
    private(set) var keyboardAdjust : CGFloat?
    private(set) var keyboardAdjustiPad : CGFloat?
    
    private let picUsercase = PicUsecase()
    private let disposeBag = DisposeBag()

    private(set) var geo = Variable<CLLocationCoordinate2D>(CLLocationCoordinate2D())

    private let locationManager = CLLocationManager()
    private(set) var maxPhotoWidth: CGFloat?
    private(set) var showLimit: Int?

    enum TargetPage : TransitionInformation {
        case selectPhoto
        case postRecruit
        case picDetail(id: String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        injectDependencies()
        self.setupView()
        self.setupLocationManager()
        self.setupNotifications()
        
        AnalyticsEventUtility.shared.send(name: .openPicPost)
    }

    override func viewWillLayoutSubviews() {
        self.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Main
extension PostPicController {
    private func injectDependencies() {
        keyboardAdjust = dependency.keyboard
        keyboardAdjustiPad = dependency.keyboardiPad
        maxPhotoWidth = dependency.photoWidth
        showLimit = dependency.titleLimit
        geo.value = dependency.defaultPlace
    }
    
    private func setupView() {
        self.titleTextField.becomeFirstResponder()
        self.titleTextField.returnKeyType = .done
        self.titleTextField.delegate = self

        // TODO: バリデーションの正式な実装
        self.titleTextField.rx.text.asObservable().bind { [weak self] title in
            guard let title = title?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                self?.recruitButton.isEnabled = false
                return
            }

            self?.recruitButton.isEnabled = title != "" && title.count <= (self?.showLimit)!
        }.disposed(by: disposeBag)
    }
    
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    private func updatePhotoButton() {
        self.photoButton.setBackgroundImage(UIImage(named: "btn_photo_white"), for: .normal)
    }
    
    private func postPic() {
        SVProgressHUD.show()
        
        picUsercase.post(title: titleTextField.text!, geo: geo.value, photoImage: postImage.image) { [weak self] (pic) in
            SVProgressHUD.dismiss()
            guard let this = self else { return }
            
            AnalyticsEventUtility.shared.send(name: .completePicPost, picId: pic.id, picOwnerUid: pic.owner?.uid)

            this.transitionDelegate?.viewController(this, needsTransitionWith: TargetPage.picDetail(id: pic.id))
        }
    }
}

// MARK: ボタンアクション
extension PostPicController {
    @IBAction func doClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doPic(sender: UIButton) {
        if (geo.value.latitude == 0 && geo.value.longitude == 0) {
            return
        }
        
        self.postPic()
    }
    
    @IBAction func doSelectPhoto() {
        self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.selectPhoto)
    }
}

// MARK: UIImagePickerControllerDelegate
extension PostPicController : UIImagePickerControllerDelegate {
    func imagePickerController(_ imagePickerController: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerController.dismiss(animated: true, completion: nil)
            self.postImage.image = image.resize(scaledToWidth: self.maxPhotoWidth!)
            self.updatePhotoButton()
        }
    }
}

extension PostPicController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// MARK: Keyboard notifications
extension PostPicController {
    @objc private func keyboardWillShow(notification: NSNotification) {
        if AppUtility.isIPad() {
            self.photoButtonTopMargin.constant -= keyboardAdjustiPad!
        }
        
        if AppUtility.isIPhoneSE() {
            self.photoButtonTopMargin.constant -= keyboardAdjust!
        }
    }
    
    @objc private func keyboardDidHide(notification: NSNotification) {
        if AppUtility.isIPad() {
            self.photoButtonTopMargin.constant += keyboardAdjustiPad!
        }

        if AppUtility.isIPhoneSE() {
            self.photoButtonTopMargin.constant += keyboardAdjust!
        }
    }
}

// MARK: UINavigationControllerDelegate
extension PostPicController : UINavigationControllerDelegate {
    
}

extension PostPicController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.geo.value = CLLocationCoordinate2DMake(manager.location!.coordinate.latitude, manager.location!.coordinate.longitude)
    }
}
