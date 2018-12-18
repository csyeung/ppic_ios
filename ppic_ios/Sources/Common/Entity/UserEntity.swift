//
//  UserEntity.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/09.

//

import SwiftyJSON

final class UserEntity {
    var bio: String
    var currentPic: PicEntity?
    var displayName: String
    var photoURL: String
    var uid: String
    
    init(root: Any) {
        let json = JSON(root)
        
        print(json)
        
        self.bio = json["bio"].stringValue
        if json["currentPic"].exists() {
            self.currentPic = PicEntity(root: json["currentPic"])
        }
        self.displayName = json["displayName"].stringValue
        self.photoURL = json["photoURL"].stringValue
        self.uid = json["uid"].stringValue
    }
    
    // TODO: BaseRepositoryでもendPointの指定をしている。一元管理するようにする
    static func thumbnailPhotoURL(uid: String) -> String {
        return "\(EnvUtility.apiEndPoint)users/\(uid)/thumbnail"
    }
    func hasPic() -> Bool{
        guard let pic = self.currentPic else{
            return false
        }
        return !pic.isExpired()
    }
}
