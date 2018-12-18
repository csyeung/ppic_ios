//
//  PicDetailController.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/11.

//

import UIKit
import RxSwift
import SVProgressHUD

final class PicDetailController: UIViewController {
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var deleteButton : UIButton!
    @IBOutlet weak var joinButton : UIButton!
    @IBOutlet weak var dmButton : UIButton!
    @IBOutlet weak var shareButton : UIButton!
    @IBOutlet weak var dmSmallButton : UIButton!
    @IBOutlet weak var listButton : UIButton!
    @IBOutlet weak var fullImage : UIImageView!
    @IBOutlet weak var profileIcon : UIImageView!
    @IBOutlet weak var usernameLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var countTitleLabel : UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var userListView : UICollectionView!
    
    var id = ""
    
    // UI設定
    private let maxShowCount : Int = 7

    private let picUsecase = PicUsecase()
    private let viewModel = PicDetailViewModel()
    
    private let disposeBag : DisposeBag = .init()

    enum TargetPage : TransitionInformation {
        case mainMap
        case chatMessage(picId: String)
        case showMyPic(picEntity: PicEntity, dynamicLink: String?)
        case share(title: String, url: String)
        case profile(uid: String)
    }
    
    enum ViewState {
        case mine
        case joined
        case join
        case unknown
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTableView()
        bindView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.load(id: id)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Main function
extension PicDetailController {
    private func setupView() {
        self.profileIcon.layer.cornerRadius = self.profileIcon.frame.height * 0.5
        self.profileIcon.layer.masksToBounds = true
    }
    
    private func setupTableView() {
        self.userListView.dataSource = self
        self.userListView.register(UINib(nibName: "AvatarCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AvatarCollectionCell")

        self.userListView.isUserInteractionEnabled = true
    }
    
    private func bindView() {
        viewModel.ownerUid.asObservable().bind { uid in
            if uid.count == 0 {
                return
            }

            self.profileIcon.isUserInteractionEnabled = true
            self.profileIcon.addGestureRecognizer(self.getUserTapGestureRecognizer(uid: uid))
            
            self.usernameLabel.isUserInteractionEnabled = true
            self.usernameLabel.addGestureRecognizer(self.getUserTapGestureRecognizer(uid: uid))

            AnalyticsEventUtility.shared.send(name: .openPicDetail, picId: self.id, picOwnerUid: uid)
        }.disposed(by: disposeBag)

        viewModel.photoURL.asObservable().bind { photoURL in
            self.fullImage.kf.setImage(with: URL(string: photoURL))
        }.disposed(by: disposeBag)
        
        viewModel.ownerPhotoURL.asObservable().bind { ownerPhotoURL in
            self.profileIcon.kf.setImage(with: URL(string: ownerPhotoURL))
        }.disposed(by: disposeBag)
        
        viewModel.ownerDisplayName.asObservable().bind(to: usernameLabel.rx.text).disposed(by: disposeBag)
        viewModel.title.asObservable().bind(to: descriptionLabel.rx.text).disposed(by: disposeBag)
        viewModel.participantsNumber.asObservable().bind(to: countLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.picUser.asObservable().bind { (picUser) in
            self.userListView.reloadData()
        }.disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.state.asObservable(), viewModel.isMine.asObservable()) { state, isMine -> ViewState in
            if isMine {
                return .mine
            } else {
                if state == .open {
                    return .join
                } else if state == .closed {
                    return .join
                } else if state == .joined {
                    return .joined
                }
            }
            
            // TODO: それ以外の状況は未対応ですから、一旦全てのボタンも非表示にします
            return .unknown
        }.bind { [weak self] result in
            // 一回全部非表示にします
            self?.deleteButton.isHidden = true
            self?.shareButton.isHidden = true
            self?.dmSmallButton.isHidden = true
            self?.listButton.isHidden = true
            self?.dmButton.isHidden = true
            self?.joinButton.isHidden = true

            switch result {
            case .mine:
                self?.deleteButton.isHidden = false
                self?.shareButton.isHidden = false
                self?.dmSmallButton.isHidden = false
                self?.listButton.isHidden = false
                break
            case .joined:
                self?.dmButton.isHidden = false
                break
            case .join:
                self?.joinButton.isHidden = false
                break
            case .unknown:
                break
            }
        }.disposed(by: disposeBag)
    }
    
    private func getUserTapGestureRecognizer(uid: String) -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer()
        
        tapGesture.rx.event.bind { [weak self] sender in
            guard let this = self else {
                return
            }
            this.transitionDelegate?.viewController(this, needsTransitionWith: TargetPage.profile(uid: uid))
        }.disposed(by: self.disposeBag)

        return tapGesture
    }
}

// MARK: ボタンアクション
extension PicDetailController {
    @IBAction func doPicClose() {
        let title = "【ピック】の終了"
        let message = "この【ピック】を終了すると、チャット記録も削除されます。\nよろしければ、OKボタンを押して終了してください。"
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in

            SVProgressHUD.show()
            self.picUsecase.close(id: self.id) { _ in
                SVProgressHUD.dismiss()
                
                AnalyticsEventUtility.shared.send(name: .completePicClose, picId: self.id, picOwnerUid: self.viewModel.ownerUid.value)
                self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.mainMap)
            }
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func doBack() {
        if let _ = self.presentingViewController as? MainMapController {
            dismiss(animated: true, completion:  nil)
            return
        }

        transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.mainMap)
    }

    @IBAction func doChatMessage() {
        switch viewModel.state.value {
        case .joined:
            transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.chatMessage(picId: id))
        case .closed:
            let title = ""
            let message = "この募集は終了しました"
            
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.default)
            
            alert.addAction(defaultAction)
            
            self.present(alert, animated: true, completion: nil)
        case .open:
            SVProgressHUD.show()
            
            AnalyticsEventUtility.shared.send(name: .tapJoinPic, picId: id, picOwnerUid: viewModel.ownerUid.value)

            viewModel.join(id: id) {
                SVProgressHUD.dismiss()
                self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.chatMessage(picId: self.id))
            }
        case .blocked:
            break
        case .unknown:
            break
        }
    }
    
    @IBAction func doShowMyPic() {
        SVProgressHUD.show()
        viewModel.pic { [weak self] pic in
            guard let this = self else { return }

            AnalyticsEventUtility.shared.send(name: .tapMyPicShow, picId: this.id, picOwnerUid: pic.owner?.uid)
 
            DynamicLinkUtility.makePickDetailLink(id: this.id) { (url) in
                SVProgressHUD.dismiss()
                this.transitionDelegate?.viewController(this, needsTransitionWith: TargetPage.showMyPic(picEntity: pic, dynamicLink: url?.absoluteString))
            }
        }
    }

    @IBAction func doShare() {
        SVProgressHUD.show()

        viewModel.pic { [weak self] pic in
            guard let this = self else { return }

            AnalyticsEventUtility.shared.send(name: .tapMyPicShare, picId: this.id, picOwnerUid: pic.owner?.uid)

            DynamicLinkUtility.makePickDetailLink(id: this.id) { (url) in
                SVProgressHUD.dismiss()

                guard let url = url else {
                    return
                }

                this.transitionDelegate?.viewController(this, needsTransitionWith: TargetPage.share(title: pic.title, url: url.absoluteString))
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension PicDetailController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = self.viewModel.picUser.value?.data.count else {
            return 0
        }
        
        return min(count, maxShowCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCollectionCell", for: indexPath) as! AvatarCollectionCell

        if let uid = self.viewModel.picUser.value?.data[indexPath.row].uid {
            cell.configure(uid: uid, with: UserEntity.thumbnailPhotoURL(uid: uid), cornerRadius: cell.frame.height * 0.5)
            print(UserEntity.thumbnailPhotoURL(uid: uid))
        }

        return cell
    }
}
