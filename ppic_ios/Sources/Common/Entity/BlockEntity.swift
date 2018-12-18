//
//  BlockEntity.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.
//

import Foundation
import Firebase

final class BlockEntity {
    var data = [BlockDataEntity]()
    var ids: [String] = []
    
    init(root: DataSnapshot) {
        for child in root.children.allObjects as! [DataSnapshot] {
            self.ids.append(child.key)
            self.data.append(BlockDataEntity(userId: child.key, root: child))
        }
        
        // TODO: createdAtの昇順で並んでいる前提のreverseなので、別の方法で解決したい
        self.data.reverse()
    }
}
