//
// Created by Jonathan YEUNG on 2018/07/19.
// ppic_ios

// 

import UIKit

final class PercentageLayoutConstraint: NSLayoutConstraint {
    @IBInspectable var marginPercent: CGFloat = 0
    
    var screenSize: (width: CGFloat, height: CGFloat) {
        return (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard marginPercent > 0 else { return }
        self.layoutDidChange()
    }
    
    /**
     Re-calculate constant based on orientation and percentage.
     */
    @objc private func layoutDidChange() {
        guard marginPercent > 0 else { return }
        
        switch firstAttribute {
        case .top, .topMargin, .bottom, .bottomMargin:
            constant = screenSize.height * marginPercent
        case .leading, .leadingMargin, .trailing, .trailingMargin, .leftMargin, .left, .right, .rightMargin:
            constant = screenSize.width * marginPercent
        default: break
        }
    }
}
