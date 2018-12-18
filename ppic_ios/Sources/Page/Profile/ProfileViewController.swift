//
// Created by Jonathan YEUNG on 2018/07/25.
// ppic_ios

// 

import NotAutoLayout
import UIKit
import RxSwift
import DIKit
import RxCocoa

final class ProfileViewController : UIViewController, PropertyInjectable {
    struct Dependency {
        let layoutHeight: CGFloat
        let viewModel: ProfileViewModelProtocol
    }
    
    private(set) lazy var mainView = LayoutInfoStoredView()
    private(set) lazy var baseView = ProfileView()
    
    private(set) var layoutHeight: CGFloat?
    private(set) var viewModel: ProfileViewModelProtocol!

    var dependency: Dependency!
    let disposeBag : DisposeBag = .init()
    
    // データ
    var photoUrl: String? {
        get {
            return self.baseView.avatar
        }
        
        set {
            self.baseView.avatar = newValue
        }
    }
    
    var displayName: String? {
        get {
            return self.baseView.userName
        }
        
        set {
            self.baseView.userName = newValue
        }
    }
    
    var bio: String? {
        get {
            return self.baseView.bio
        }
        
        set {
            self.baseView.bio = newValue
        }
    }

    enum TargetPage : TransitionInformation {
        case setting
        case menu(uid: String)
    }

    override func loadView() {
        self.mainView.frame = UIScreen.main.bounds
        self.view = self.mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        injectDependencies()

        setupView()
        bindData()
        
        AnalyticsEventUtility.shared.send(name: .openProfile, picId: nil, picOwnerUid: nil, optionalParameters: [
            "target_uid": viewModel.uid
        ])
    }
}

// MARK: Main function
extension ProfileViewController {
    private func injectDependencies() {
        self.layoutHeight = dependency.layoutHeight
        self.viewModel = dependency.viewModel
    }
    
    func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        self.mainView.nal.setupSubview(self.baseView) { $0
            .setDefaultLayout({ $0
                .setMiddleCenter(by: { $0.layoutMarginsGuide.middleCenter })
                .setLeft(by: { $0.layoutMarginsGuide.left })
                .setHeight(to: Float(self.layoutHeight!))
                .addingProcess(by: { (_, parameters) in
                    parameters.targetView.layer.backgroundColor = UIColor.white.cgColor
                    parameters.targetView.layer.cornerRadius = 8
                })
            })
            .setDefaultOrder(to: 1)
            .addToParent()
        }
        
        // 外側でタップすると閉じれる仕組み
        let tapGesture = UITapGestureRecognizer()
        
        tapGesture.rx.event.bind { [weak self] sender in
            if let response = self?.baseView.point(inside: sender.location(in: self?.baseView), with: nil) {
                if !response {
                    self?.onClose(sender: sender)
                }
            }
        }.disposed(by: disposeBag)
        
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func bindData() {
        viewModel.profileData
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(rx.profileDataBinder())
            .disposed(by: disposeBag)
    }
}

private extension Reactive where Base: ProfileViewController {
    func profileDataBinder() -> Binder<(String, String, String)> {
        return .init(base, binding: { (base, value) in
            base.photoUrl = value.0
            base.displayName = value.1
            base.bio = value.2
        })
    }
}

extension ProfileViewController {
    func showInView(controller: UIViewController, animated: Bool = false) {
        self.view.frame = controller.view.frame
        
        if let topController = controller.navigationController {
            topController.addChildViewController(self)
            topController.view.addSubview(self.view)
            self.didMove(toParentViewController: topController)
        } else {
            controller.addChildViewController(self)
            controller.view.addSubview(self.view)
            self.didMove(toParentViewController: controller)
        }
        
        if animated {
            self.showAnimate()
        }
    }
    
    func showAnimate() {
        self.baseView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.baseView.alpha = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.baseView.alpha = 1
            self.baseView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    func hideAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.baseView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.baseView.alpha = 0
        }, completion: { finished in
            if finished {
                self.view.removeFromSuperview()
            }
        })
    }
}

// Mark: - IBAction
extension ProfileViewController {
    public func onClose(sender: AnyObject) {
        self.hideAnimate()
    }
    
    public func showMenu(sender: AnyObject) {
        var target : TargetPage = .menu(uid: self.viewModel.uid)
        
        if self.viewModel.isMine {
            target = .setting
        }
        
        self.transitionDelegate?.viewController(self, needsTransitionWith: target)
    }
}

