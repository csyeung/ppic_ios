//
//  ChatMessageRepository.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation
import Firebase

protocol ChatMessageRepositoryProtocol {
    func observe(picId: String, on: @escaping (DataSnapshot) -> Void)

    func send(picId: String, content: String, completion: @escaping () -> Void)
}

final class ChatMessageRepository {
}

extension ChatMessageRepository: ChatMessageRepositoryProtocol {
    func observe(picId: String, on: @escaping (DataSnapshot) -> Void) {
        self.getRef(picId: picId) { (ref) in
            ref.observe(DataEventType.value) { (snapshot) in
                on(snapshot)
            }
        }
    }
    
    func send(picId: String, content: String, completion: @escaping () -> Void) {
        let userRepository = UserRepository()
        
        userRepository.findMine { (user) in
            self.getRefForWrite(picId: picId) { (ref) in
                let now = Date();
                let seconds = now.timeIntervalSince1970
                let milliseconds = UInt64(seconds * 1000)

                ref.child(milliseconds.description).setValue([
                    "userID": user.uid,
                    "content": content,
                    "createdAt": now.toISO()
                    ])
                
                completion()
            }
        }
    }

    private func getRef(picId: String, completion: @escaping (DatabaseQuery) -> Void) {
        completion(Database.database().reference().child("messages/\(picId)").queryOrderedByKey())
    }

    private func getRefForWrite(picId: String, completion: @escaping (DatabaseReference) -> Void) {
        completion(Database.database().reference().child("messages/\(picId)"))
    }
}
