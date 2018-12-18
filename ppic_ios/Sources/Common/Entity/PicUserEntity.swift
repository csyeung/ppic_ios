//
//  PicUserEntity.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation
import SwiftyJSON

final class PicUserEntity {
    var after = ""
    var data = [UserEntity]()
    
    init(root: Any) {
        let json = JSON(root)
        
        for user in json["data"].arrayValue {
            data.append(UserEntity(root: user))
        }
    }
}
