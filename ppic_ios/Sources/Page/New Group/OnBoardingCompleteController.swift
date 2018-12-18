//
//  OnBoardingCompleteController.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/18.

//

import UIKit

final class OnBoardingCompleteController: UIViewController, BaseOnBoardingStub {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var bgImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgImageViewBottomConstraint: NSLayoutConstraint!
    
    private let slug = "complete"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        AnalyticsEventUtility.shared.send(name: .openOnBoardingComplete)
    }
}

// MARK: Main function
extension OnBoardingCompleteController {
    private func setupView() {
        bgImageViewTopConstraint.constant -= UIApplication.shared.statusBarFrame.size.height
        bgImageView.image = UIImage(named: getBgImageName(slug: slug))
        buttonBottomConstraint.constant += getBottomMargin()
        
        // TODO: 画像の背景色が白ではなくグラデーションが施されているので、余白を生まないための応急処置
        if AppUtility.isIPhoneX() {
            bgImageViewBottomConstraint.constant -= 34
        }
        
        // TODO: 画像の背景色が白ではなくグラデーションが施されているので、余白を生まないための応急処置
        if AppUtility.isIPad() {
            bgImageViewTopConstraint.constant -= 100
            bgImageViewBottomConstraint.constant -= UIApplication.shared.statusBarFrame.size.height + 70
        }
    }
}

// MARK: IBAction
extension OnBoardingCompleteController {
    @IBAction func doNext() {
        AnalyticsEventUtility.shared.send(name: .completeOnBoarding)

        self.appDelegate?.transitionDelegate?.viewController(self, needsTransitionWith: OnBoardingPage.next)
    }
}
