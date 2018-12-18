//
//  ChatListDataEntity.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/11.

//

import Foundation
import Firebase

final class ChatListDataEntity {
    var picId: String?
    var unread: Bool?
    var latest: (content: String?, createdAt: Date?, createdBy: String?, isBlocked: Bool?) = (content: nil, createdAt: nil, createdBy: nil, isBlocked: nil)

    init(picId: String, root: DataSnapshot) {
        self.picId = picId

        // https://firebase.google.com/docs/database/ios/read-and-write?hl=ja
        let value = root.value as? NSDictionary
        let latest = value?["latest"] as? NSDictionary
        
        self.unread = value?["unread"] as? Bool
        
        self.latest = (
            content: latest?["content"] as? String,
            createdAt: (latest?["createdAt"] as? String)?.toISODate()?.date,
            createdBy: latest?["createdBy"] as? String,
            isBlocked: latest?["isBlocked"] as? Bool
        )
    }
}
