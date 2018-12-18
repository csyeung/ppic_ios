//
//  ChatMessageEntity.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation
import Firebase

final class ChatMessageEntity {
    var data = [ChatMessageDataEntity]()
    
    init(root: DataSnapshot) {
        for child in root.children.allObjects as! [DataSnapshot] {
            self.data.append(ChatMessageDataEntity(milliseconds: child.key, root: child))
        }
    }
}
