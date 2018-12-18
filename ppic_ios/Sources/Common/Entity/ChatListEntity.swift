//
//  ChatListEntity.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/11.

//

import Foundation
import Firebase

final class ChatListEntity {
    var data = [ChatListDataEntity]()

    init(root: DataSnapshot) {
        for child in root.children.allObjects as! [DataSnapshot] {
            self.data.append(ChatListDataEntity(picId: child.key, root: child))
        }
        
        // TODO: createdAtの昇順で並んでいる前提のreverseなので、別の方法で解決したい
        self.data.reverse()
    }
}
