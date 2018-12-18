//
//  BlockDataEntity.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation
import Firebase

final class BlockDataEntity {
    var userId: String?
    var createdAt: Date?
    var direction: Direction = .unknown

    enum Direction: String {
        case blocking = "blocking"
        case blocked = "blocked"
        case unknown = "unknown"
    }

    init(userId: String, root: DataSnapshot) {
        self.userId = userId

        // https://firebase.google.com/docs/database/ios/read-and-write?hl=ja
        let value = root.value as? NSDictionary
        self.createdAt = (value?["createdAt"] as? String)?.toISODate()?.date

        if let direction = Direction(rawValue: value?["direction"] as! String) {
            self.direction = direction
        }
    }
}
