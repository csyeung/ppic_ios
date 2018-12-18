//
//  PicEntity.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/09.

//

import SwiftyJSON

final class PicEntity {
    var expiredAt: Date?
    var geo: (latitude: Double, longitude: Double) = (0, 0)
    var id: String
    var owner: UserEntity?
    var photoURL: String
    var title: String
    var state: State = .unknown
    var thumbnailURL: String
    var participantsNumber: Int
    
    enum State: String {
        case closed = "closed"
        case open = "open"
        case joined = "joined"
        case blocked = "blocked"
        case unknown = "unknown"
    }

    init(root: Any) {
        let json = JSON(root)
        
        print(json)
        
        self.geo = (json["geo", "latitude"].doubleValue, json["geo", "longitude"].doubleValue)
        self.id = json["id"].stringValue
        
        if json["owner"].exists() {
            self.owner = UserEntity(root: json["owner"])
        }
        
        self.photoURL = json["photoURL"].stringValue
        self.title = json["title"].stringValue

        if let state = State(rawValue: json["state"].stringValue) {
            self.state = state
        }
        self.thumbnailURL = json["thumbnailURL"].stringValue
        self.participantsNumber = json["participantsNumber"].intValue
        
        let expiry = json["expiredAt"].stringValue
        self.expiredAt = expiry.toISODate()?.date
    }
    func isExpired() -> Bool{
        guard let expiredAt = self.expiredAt else{
            return false
        }
        return expiredAt.timeIntervalSinceNow <= 0
    }
}
