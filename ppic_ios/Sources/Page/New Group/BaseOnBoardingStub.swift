//
// Created by Jonathan YEUNG on 2018/07/26.
// ppic_ios

// 

import UIKit

enum OnBoardingPage: TransitionInformation {
    case next
}

protocol BaseOnBoardingStub {
    func getBgImageName(slug: String) -> String
    func getBottomMargin() -> CGFloat
}

extension BaseOnBoardingStub {
    internal func getBgImageName(slug: String) -> String {
        let imageSuffix = AppUtility.isIPhoneX() ? "_x" : ""
        return "onboarding_\(slug)_bg" + imageSuffix
    }
    
    internal func getBottomMargin() -> CGFloat {
        return AppUtility.isIPhoneX() ? 0 : 24
    }
}
