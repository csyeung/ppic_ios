//
//  BlockRepository.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation
import Firebase

protocol BlockRepositoryProtocol {
    func observeSingleEvent(on: @escaping (DataSnapshot) -> Void)
    
    func create(userId: String)
    
    func delete(userId: String)
}

final class BlockRepository {
    let userRepository = UserRepository()
}

extension BlockRepository: BlockRepositoryProtocol {
    func observeSingleEvent(on: @escaping (DataSnapshot) -> Void) {
        self.getRef { (ref) in
            ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                on(snapshot)
            })
        }
    }
    
    func create(userId: String) {
        self.getRefForWrite() { (ref) in
            let now = Date()

            ref.child(userId).setValue([
                "createdAt": now.toISO(),
                "direction": BlockDataEntity.Direction.blocking.rawValue
            ])
        }
    }
    
    func delete(userId: String) {
        self.getRefForWrite() { (ref) in
            // not implemented yet
        }
    }
    
    private func getRef(completion: @escaping (DatabaseQuery) -> Void) {
        userRepository.findMine { (user) in
            completion(Database.database().reference().child("blocks/\(user.uid)").queryOrdered(byChild: "createdAt"))
        }
    }

    private func getRefForWrite(completion: @escaping (DatabaseReference) -> Void) {
        userRepository.findMine { (user) in
            completion(Database.database().reference().child("blocks/\(user.uid)"))
        }
    }
}
