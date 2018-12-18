//
//  OnBoardingWelcomeController.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/18.

//

import Foundation
import UIKit

final class OnBoardingWelcomeController: BaseViewController, BaseOnBoardingStub {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var bgImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!

    private let slug = "welcome"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        AnalyticsEventUtility.shared.send(name: .openOnBoardingWelcome)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: Main function
extension OnBoardingWelcomeController {
    private func setupView() {
        bgImageViewTopConstraint.constant -= UIApplication.shared.statusBarFrame.size.height
        bgImageView.image = UIImage(named: getBgImageName(slug: slug))
        buttonBottomConstraint.constant += getBottomMargin()
    }
}

// MARK: IBAction
extension OnBoardingWelcomeController {
    @IBAction func doNext() {
        self.appDelegate?.transitionDelegate?.viewController(self, needsTransitionWith: OnBoardingPage.next)
    }
}
