//
// Created by Jonathan YEUNG on 2018/07/10.
// ppic_ios

// 

import UIKit

extension UIView {
    var parentViewController : UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
