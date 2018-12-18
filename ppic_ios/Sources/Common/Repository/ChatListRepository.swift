//
//  ChatListRepository.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/11.

//

import Foundation
import Firebase

protocol ChatListRepositoryProtocol {
    func observe(on: @escaping (DataSnapshot) -> Void)
    
    func read(picId: String)
}

final class ChatListRepository {
    let userRepository = UserRepository()
}

extension ChatListRepository: ChatListRepositoryProtocol {
    func observe(on: @escaping (DataSnapshot) -> Void) {
        self.getRef { (ref) in
            ref.observe(DataEventType.value) { (snapshot) in
                on(snapshot)
            }
        }
    }
    
    func read(picId: String) {
        self.getRefForWrite(picId: picId) { (ref) in
            ref.child("unread").setValue(false)
        }
    }
 
    private func getRef(completion: @escaping (DatabaseQuery) -> Void) {
        userRepository.findMine { (user) in
            completion(Database.database().reference().child("chat/\(user.uid)").queryOrdered(byChild: "latest/createdAt"))
        }
    }

    private func getRefForWrite(picId: String, completion: @escaping (DatabaseReference) -> Void) {
        userRepository.findMine { (user) in
            completion(Database.database().reference().child("chat/\(user.uid)/\(picId)"))
        }
    }
}
