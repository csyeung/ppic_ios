//
//  UIImageExtension.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/10.

//

import UIKit

extension UIImage {
    func base64JPEG() -> String? {
        guard let data = UIImageJPEGRepresentation(self, 1) else {
            return nil
        }

        return "data:image/jpeg;base64," + data.base64EncodedString()
    }

    func base64PNG() -> String? {
        guard let data = UIImagePNGRepresentation(self) else {
            return nil
        }
        
        return "data:image/png;base64," + data.base64EncodedString()
    }

    // https://stackoverflow.com/questions/7645454/resize-uiimage-by-keeping-aspect-ratio-and-width
    func resize(scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = self.size.width
        
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        if (oldWidth <= newWidth) {
            return self
        }
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        
        self.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
