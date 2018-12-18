//
// Created by Jonathan YEUNG on 2018/07/10.
// ppic_ios

// 

import UIKit

class AppUtility {
    // 色から背景画像を作る仕組み
    static func makeImageWithColorAndHeight(color: UIColor, height: Double) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1 * height)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    static func makeDMCountString(count: Int) -> String {
        let string = count < 100 ? "\(count)" : "99+"
        
        return "(\(string))"
    }
    
    static func makeWidthFromDistance(zoomLevel: Double, latitude: Double) -> Double {
        return 156534.04 * cos(latitude) / pow(2, zoomLevel)
    }

    static func isIPhoneX() -> Bool {
        return UIScreen.main.bounds.height == 812
    }
    
    static func isIPhoneSE() -> Bool {
        return UIScreen.main.nativeBounds.height == 1136
    }
    
    static func isIPad() -> Bool {
        return UIScreen.main.bounds.height == 480
    }
}
