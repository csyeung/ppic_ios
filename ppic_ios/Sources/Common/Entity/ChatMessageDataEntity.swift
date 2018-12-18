//
//  ChatMessageDataEntity.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation
import Firebase

final class ChatMessageDataEntity {
    var milliseconds: String?
    var userId: String?
    var content: String?
    var createdAt: Date?
    
    init(milliseconds: String, root: DataSnapshot) {
        self.milliseconds = milliseconds
        
        // https://firebase.google.com/docs/database/ios/read-and-write?hl=ja
        let value = root.value as? NSDictionary
        
        self.userId = value?["userID"] as? String
        self.content = value?["content"] as? String
        self.createdAt = (value?["createdAt"] as? String)?.toISODate()?.date
    }
}
