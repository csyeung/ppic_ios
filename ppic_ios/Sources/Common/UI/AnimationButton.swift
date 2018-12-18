//
// Created by Jonathan YEUNG on 2018/07/17.
// ppic_ios
// 

import UIKit

class AnimationButton : UIButton {
    override open var isHighlighted: Bool {
        didSet {
            updateAnimation(isOn: isHighlighted)
        }
    }

    private func updateAnimation(isOn: Bool) {
        CATransaction.begin()

        if isOn {
            CATransaction.setAnimationDuration(0.2)
        } else {
            CATransaction.setDisableActions(true)
        }

        var scale : CGFloat = 1

        if state.contains(.highlighted) {
            scale = 0.9
        }

        self.layer.sublayerTransform = CATransform3DMakeScale(scale, scale, scale)
        CATransaction.commit()
    }
}
