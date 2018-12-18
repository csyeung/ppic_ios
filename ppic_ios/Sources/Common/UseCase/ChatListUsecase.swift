//
//  ChatListUsecase.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/11.

//

import Foundation
import Firebase

protocol ChatListUsecaseProtocol {
    func observe(on: @escaping (ChatListEntity) -> Void)

    func read(picId: String)

    func removeBadge()
}

final class ChatListUsecase {
    private let repository = ChatListRepository()
}

extension ChatListUsecase: ChatListUsecaseProtocol {
    func observe(on: @escaping (ChatListEntity) -> Void) {
        repository.observe { (snapshot) in
            on(ChatListEntity(root: snapshot))
        }
    }
    
    func read(picId: String) {
        repository.read(picId: picId)
    }

    func removeBadge(){
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
    }
}
