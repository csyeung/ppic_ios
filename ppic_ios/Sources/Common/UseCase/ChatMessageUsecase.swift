//
//  ChatMessageUsecase.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation
import Firebase

protocol ChatMessageUsecaseProtocol {
    func observe(picId: String, on: @escaping (ChatMessageEntity) -> Void)

    func send(picId: String, content: String, completion: @escaping () -> Void)
}

final class ChatMessageUsecase {
    private let repository = ChatMessageRepository()
}

extension ChatMessageUsecase: ChatMessageUsecaseProtocol {
    func send(picId: String, content: String, completion: @escaping () -> Void) {
        repository.send(picId: picId, content: content, completion: completion)
    }

    func observe(picId: String, on: @escaping (ChatMessageEntity) -> Void) {
        repository.observe(picId: picId) { (snapshot) in
            on(ChatMessageEntity(root: snapshot))
        }
    }
}
