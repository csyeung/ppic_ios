//
//  OnBoardingRegisterController.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/18.

//

import UIKit
import CropViewController
import SVProgressHUD
import RxSwift

final class OnBoardingRegisterController: UIViewController, BaseOnBoardingStub {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var bgImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var photoImageViewTopConstraintIPad: NSLayoutConstraint!
    @IBOutlet weak var photoImageViewTopConstraintX: NSLayoutConstraint!
    @IBOutlet weak var photoImageViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var button: UIButton!

    private let slug = "register"
    private let keyboardAdjust: CGFloat = 30
    private let keyboardAdjustiPad: CGFloat = 60
    private(set) var frameOrigin: CGFloat = 0

    private let disposeBag = DisposeBag()
    private let userUsecase = UserUsecase()

    enum MyTargetPage : TransitionInformation {
        case choicePhoto
        case cropPhoto(image: UIImage)
        case web(title: String, url: String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNotifications()
        bindView()

        AnalyticsEventUtility.shared.send(name: .openOnBoardingRegister)
    }
    
    override func viewWillLayoutSubviews() {
        updateViewConstraints()
    }

    override func updateViewConstraints() {
        photoImageViewTopConstraintX.isActive = AppUtility.isIPhoneX()
        photoImageViewTopConstraintIPad.isActive = AppUtility.isIPad()
        photoImageViewTopConstraint.isActive = !AppUtility.isIPhoneX() && !AppUtility.isIPad()
        
        super.updateViewConstraints()
    }
}


// MARK: Main function
extension OnBoardingRegisterController {
    private func setupView() {
        frameOrigin = self.view.frame.origin.y
        
        bgImageViewTopConstraint.constant -= UIApplication.shared.statusBarFrame.size.height
        bgImageView.image = UIImage(named: getBgImageName(slug: slug))
        buttonBottomConstraint.constant += getBottomMargin()
        
        displayNameField.returnKeyType = .done
        displayNameField.becomeFirstResponder()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func bindView() {
        displayNameField.rx.text.asObservable().bind { displayName in
            self.button.isEnabled = self.registerable()
        }.disposed(by: disposeBag)
        
        displayNameField.delegate = self
    }
    
    private func registerable() -> Bool {
        guard let displayName = displayNameField.text else {
            return false
        }
        
        return (displayName.count >= 1 && displayName.count <= 15) && agreeButton.isSelected
    }
}

// MARK: IBAction
extension OnBoardingRegisterController {
    @IBAction func doNext() {
        if !registerable() {
            return
        }

        SVProgressHUD.show()
        
        userUsecase.register(displayName: displayNameField.text!, photoImage: photoButton.imageView?.image) { [weak self] (user) in
            SVProgressHUD.dismiss()
            
            guard let this = self else { return }
            
            this.appDelegate?.transitionDelegate?.viewController(this, needsTransitionWith: OnBoardingPage.next)
        }
    }

    @IBAction func doChoicePhoto() {
        self.transitionDelegate?.viewController(self, needsTransitionWith: MyTargetPage.choicePhoto)
    }

    @IBAction func toggleAgree() {
        self.agreeButton.isSelected = !self.agreeButton.isSelected
        self.button.isEnabled = self.registerable()
    }

    @IBAction func toTerms() {
        self.appDelegate?.transitionDelegate?.viewController(self, needsTransitionWith: MyTargetPage.web(title: "利用規約", url: "https://flipmap.co/terms2"))
    }

    @IBAction func toPrivacy() {
        self.appDelegate?.transitionDelegate?.viewController(self, needsTransitionWith: MyTargetPage.web(title: "プライバシーポリシー", url: "http://www.fullspeed.co.jp/privacy/"))
    }
}

extension OnBoardingRegisterController : UIImagePickerControllerDelegate {
    func imagePickerController(_ imagePickerController: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // TODO: 330という値は、ユーザ画像の最大解像度。どこかに名前をつけて定義すべき
            self.transitionDelegate?.viewController(self, needsTransitionWith: MyTargetPage.cropPhoto(image: image.resize(scaledToWidth: 330)))
        }
    }
}

extension OnBoardingRegisterController : CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        photoButton.setImage(image, for: .normal)

        self.transitionDelegate?.viewController(cropViewController, needsTransitionWith: nil)
    }
}

// MARK: Keyboard notifications
extension OnBoardingRegisterController {
    @objc private func keyboardWillShow(notification: NSNotification) {
        if AppUtility.isIPad() {
            self.view.frame.origin.y -= keyboardAdjustiPad
        }
        
        if AppUtility.isIPhoneSE() {
            self.view.frame.origin.y -= keyboardAdjust
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if AppUtility.isIPad() {
            self.view.frame.origin.y = frameOrigin
        }
        
        if AppUtility.isIPhoneSE() {
            self.view.frame.origin.y = frameOrigin
        }
    }
}

// MARK: UINavigationControllerDelegate
extension OnBoardingRegisterController : UINavigationControllerDelegate {
    
}

// MARK: UITextFieldDelegate
extension OnBoardingRegisterController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        let displayNameMaxLength = 15

        return text.count + string.count <= displayNameMaxLength
    }
}
