//
// Created by Jonathan YEUNG on 2018/07/06.
// ppic_ios

// 

import UIKit

// MARK: AppDelegate簡単にアクセスできるように
extension UIViewController {
    var appDelegate : AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }

    var transitionDelegate : TransitionDelegate? {
        return appDelegate?.transitionDelegate
    }
}
