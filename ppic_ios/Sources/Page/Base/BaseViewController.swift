//
// Created by Jonathan YEUNG on 2018/07/26.
// ppic_ios

// 

import UIKit
import CropViewController

// MARK: 遷移する時必要な情報
protocol TransitionInformation {
    
}

// MARK: 遷移を管理するデリゲート
protocol TransitionDelegate : class {
    func viewController(_ controller : UIViewController, needsTransitionWith information : TransitionInformation?)
}

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate?.transitionDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.transitionDelegate?.viewController(self, needsTransitionWith: nil)
    }
}

extension BaseViewController: TransitionDelegate {
    // 画面遷移に関する部分はこちら対応します
    internal func viewController(_ controller: UIViewController, needsTransitionWith information: TransitionInformation?) {
        switch (controller, information) {
        // MainMapController
        case (let mainMap as MainMapController, let page as MainMapController.TargetPage):
            switch page {
            case .profile(let uid):
                self.showProfile(on: mainMap, uid: uid)
            case .message:
                self.showMessageList(on: mainMap)
            case .recruit:
                self.showPostPic(on: mainMap)
            case .pickShow(let id):
                self.showPicDetail(on: mainMap, id: id)
            }
            
        case (_ as MainMapController, nil):
            // TODO: 初回表示の判断、募集画面の表示？
            print("Do Nothing")
            
        case (let profile as ProfileViewController, let page as ProfileViewController.TargetPage):
            switch page {
            case .menu(let uid):
                self.showProfileActionMenu(controller: profile, uid: uid)
            case .setting:
                self.showSetting(on: profile)
            }
            
        case (let crop as CropViewController, nil):
            crop.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            
        case (let dm as DirectMessageController, let page as DirectMessageController.TargetPage):
            switch page {
            case .picDetail(let id):
                self.showPicDetail(on: dm, id: id)
            case .profile(let uid):
                self.showDMActionMenu(controller: dm, uid: uid)
            case .dismiss:
                if let _ = dm.navigationController?.viewControllers.first as? DirectMessageController {
                    dm.dismiss(animated: true, completion: nil)
                    return
                }
                
                dm.navigationController?.popViewController(animated: true)
            }
        case (_ as DirectMessageController, nil):
            break
            
        case (_ as SettingController, nil):
            break
            
        case (let recruit as PostPicController, let page as PostPicController.TargetPage):
            switch page {
            case .postRecruit:
                break
            case .selectPhoto:
                if let photoAlbum = self.makePhotoAlbum(delegate: recruit) {
                    recruit.present(photoAlbum, animated: true, completion: nil)
                }
            case .picDetail(let id):
                self.showPicDetail(on: recruit, id: id)
            }
            
        case (let setting as SettingController, let page as SettingController.TargetPage):
            switch page {
            case .webView(let title, let url):
                if let webController = self.makeWebView(title: title, url: url) {
                    setting.present(webController, animated: true, completion: nil)
                }
            case .selectPhoto:
                if let photoAlbum = self.makePhotoAlbum(delegate: setting) {
                    setting.present(photoAlbum, animated: true, completion: nil)
                }
            case .cropPhoto(let image):
                let cropView = self.makeCropView(on: setting, image: image)
                setting.presentedViewController?.present(cropView, animated: true, completion: nil)
            }
            
        case (let picDetail as PicDetailController, let page as PicDetailController.TargetPage):
            switch page {
            case .chatMessage(let picId):
                self.showChatMessage(on: picDetail, picId: picId)
            case .mainMap:
                self.showMainMap(on: picDetail)
            case .showMyPic(let picEntity, let dynamicLink):
                self.showPicOnMap(controller: picDetail, picEntity: picEntity, dynamicLink: dynamicLink)
            case .share(let title, let url):
                let activityItems = [title, NSURL(string: url)!] as [Any]
                let next = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                picDetail.present(next, animated: true, completion: nil)
            case .profile(let uid):
                self.showProfile(on: picDetail, uid: uid)
            }
            
        case (_ as PicDetailController, nil):
            break
            
        case (let dmList as DirectMessageListController, let page as DirectMessageListController.TargetPage):
            switch page {
            case .chatDetails(let picId):
                self.showChatMessage(on: dmList, picId: picId)
            case .dismiss:
                dmList.dismiss(animated: true, completion: nil)
            }
            
        case (let onboarding as OnBoardingWelcomeController, let page as OnBoardingPage):
            switch page {
            case .next:
                guard let next = UIStoryboard(name: "OnBoardingShare", bundle: nil).instantiateInitialViewController() as? OnBoardingShareController else { return }
                
                onboarding.navigationController?.pushViewController(next, animated: true)
            }
            
        case (_ as OnBoardingWelcomeController, nil):
            break
            
        case (let onboarding as OnBoardingShareController, let page as OnBoardingPage):
            switch page {
            case .next:
                guard let next = UIStoryboard(name: "OnBoardingRegister", bundle: nil).instantiateInitialViewController() as? OnBoardingRegisterController else { return }
                
                onboarding.navigationController?.pushViewController(next, animated: true)
            }
            
        case (_ as OnBoardingShareController, nil):
            break
            
        case (let onboarding as OnBoardingRegisterController, let page as OnBoardingRegisterController.MyTargetPage):
            switch page {
            case .choicePhoto:
                if let photoAlbum = self.makePhotoAlbum(delegate: onboarding) {
                    onboarding.present(photoAlbum, animated: true, completion: nil)
                }
            case .cropPhoto(let image):
                let cropView = self.makeCropView(on: onboarding, image: image)
                onboarding.presentedViewController?.present(cropView, animated: true, completion: nil)
            case .web(let title, let url):
                if let webController = self.makeWebView(title: title, url: url) {
                    onboarding.present(webController, animated: true, completion: nil)
                }
            }
            
        case (let onboarding as OnBoardingRegisterController, let page as OnBoardingPage):
            switch page {
            case .next:
                guard let next = UIStoryboard(name: "OnBoardingComplete", bundle: nil).instantiateInitialViewController() as? OnBoardingCompleteController else { return }
                
                onboarding.navigationController?.pushViewController(next, animated: true)
            }
            
        case (_ as OnBoardingRegisterController, nil):
            break
            
        case (let onboarding as OnBoardingCompleteController, let page as OnBoardingPage):
            switch page {
            case .next:
                self.showMainMap(on: onboarding, modalTransitionStyle: .crossDissolve)
            }
            
        case (_ as OnBoardingCompleteController, nil):
            break
            
        case (let web as WebController, nil):
            web.dismiss(animated: true, completion: nil)
            
        case let invalid:
            assertionFailure(invalid.0.description)
        }
    }
}

// 共通利用するメソッド
private extension BaseViewController {
    private func makeCropView(on controller: CropViewControllerDelegate, image: UIImage) -> CropViewController {
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = controller
        return cropViewController
    }
    
    private func makeWebView(title: String, url: String) -> UINavigationController? {
        guard let next = UIStoryboard(name: "Web", bundle: nil).instantiateInitialViewController() as? UINavigationController else { return nil }
        guard let web = next.topViewController as? WebController else { return nil }
        web.title = title
        web.url = url
        
        return next
    }
    
    private func makePhotoAlbum(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> UIImagePickerController? {
        let sourceType : UIImagePickerControllerSourceType = .photoLibrary
        
        // カメラが利用可能かチェック
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true else {
            return nil
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = sourceType
        cameraPicker.delegate = delegate
        
        return cameraPicker
    }
}

// MARK: 特定なページの作成
private extension BaseViewController {
    private func showMainPage() {
        self.appDelegate?.toMainPage()
    }
    
    private func showProfile(on controller: UIViewController, uid: String) {
        let profile = ProfileViewController()
        self.appDelegate?.appResolver.inject(toProfileViewController: profile, uid: uid)
        profile.showInView(controller: controller, animated: true)
    }
    
    private func showProfileActionMenu(controller: ProfileViewController, uid: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let block = UIAlertAction(title: "このユーザーをブロックする", style: .destructive, handler: { _ in
            let blockUsecase = BlockUsecase()
            blockUsecase.block(userId: uid)
            controller.dismiss(animated: true, completion: nil)
        })
        alert.addAction(block)
        
        let report = UIAlertAction(title: "通報", style: .destructive, handler: { _ in
            self.getReportUrl(completion: { (url) in
                if let webController = self.makeWebView(title: "通報", url: url) {
                    controller.present(webController, animated: true, completion: nil)
                }
            })
        })
        alert.addAction(report)
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    private func showMessageList(on controller: UIViewController) {
        guard let next = UIStoryboard(name: "DirectMessageList", bundle: nil).instantiateInitialViewController() else {return}
        controller.present(next, animated: true, completion: nil)
    }
    
    private func showDMActionMenu(controller: UIViewController, uid: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // プロフィールを表示
        let profile = UIAlertAction(title: "プロフィールを表示", style: .default, handler: { [weak self] _ in
            self?.showProfile(on: controller, uid: uid)
        })
        alert.addAction(profile)
        
        // 発言を通報
        let report = UIAlertAction(title: "発言を通報", style: .destructive, handler: { _ in
            self.getReportUrl(completion: { (url) in
                if let webController = self.makeWebView(title: "通報", url: url) {
                    controller.present(webController, animated: true, completion: nil)
                }
            })
        })
        alert.addAction(report)
        
        // キャンセル
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    private func showPostPic(on controller: UIViewController) {
        guard let next = UIStoryboard(name: "PostPic", bundle: nil).instantiateInitialViewController() as? PostPicController else { return }
        let resolver = ProductionAppResolver()
        resolver.inject(toPostPicController: next)
        controller.present(next, animated: true, completion: nil)
    }
    
    private func showPicDetail(on controller: UIViewController, id: String) {
        guard let next = UIStoryboard(name: "PicDetail", bundle: nil).instantiateInitialViewController() as? PicDetailController else { return }
        next.id = id
        
        controller.present(next, animated: true, completion: nil)
    }
    
    private func showChatMessage(on controller: UIViewController, picId: String) {
        guard let next = UIStoryboard(name: "DirectMessage", bundle: nil).instantiateInitialViewController() as? UINavigationController else { return }
        
        let directMessageController = next.viewControllers.first as! DirectMessageController
        directMessageController.picId = picId
        
        if let navigationController = controller.navigationController {
            navigationController.pushViewController(directMessageController, animated: true)
            return
        }
        
        controller.present(next, animated: true, completion: nil)
    }
    
    private func showSetting(on controller: UIViewController) {
        guard let next = UIStoryboard(name: "Setting", bundle: nil).instantiateInitialViewController() as? SettingController else { return }
        self.appDelegate?.appResolver.inject(toSettingController: next)
        controller.present(next, animated: true, completion: nil)
    }
    
    private func showMainMap(on controller: UIViewController, modalTransitionStyle: UIModalTransitionStyle = .coverVertical) {
        guard let next = UIStoryboard(name: "MainMap", bundle: nil).instantiateInitialViewController() as? MainMapController else { return }
        self.appDelegate?.appResolver.inject(toMainMapController: next)
        next.modalTransitionStyle = modalTransitionStyle
        controller.present(next, animated: true, completion: nil)
    }
    
    private func getReportUrl(completion: @escaping (String) -> Void) {
        let userUsecase = UserUsecase()
        userUsecase.getMyProfile(completion: { (user) in
            let url = "https://docs.google.com/forms/d/e/1FAIpQLSdCpbjw3rdz8Z5uqQvuEf27x3rQn9OwC-0N0heScYdu16p2ig/viewform?usp=pp_url&entry.1653334365=" + user.uid
            completion(url)
        })
    }
    
    private func showPicOnMap(controller: UIViewController, picEntity: PicEntity, dynamicLink: String?) {
        if let mapController = controller.presentingViewController as? MainMapController {
            mapController.setMyPic(pic: picEntity, dynamicLink: dynamicLink)
            
            controller.dismiss(animated: true, completion: {
                mapController.setMyPic(pic: picEntity, dynamicLink: dynamicLink)
            })
            
            return
        }
        
        guard let next = UIStoryboard(name: "MainMap", bundle: nil).instantiateInitialViewController() as? MainMapController else { return }
        self.appDelegate?.appResolver.inject(toMainMapController: next)
        controller.present(next, animated: true, completion: {
            next.setMyPic(pic: picEntity, dynamicLink: dynamicLink)
        })
    }
}
