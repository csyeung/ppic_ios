//
// Created by Jonathan YEUNG on 2018/07/11.
// ppic_ios

// 

import Foundation

final class DirectMessageListViewModel {
    private let chatListUsecase = ChatListUsecase()

    var messageThreads: [ChatListDataEntity] = []

    func observe(on: @escaping (ChatListEntity) -> Void) {
        chatListUsecase.observe(on: { (chatList) in
            self.messageThreads = chatList.data

            on(chatList)
        })
    }
    func removeBadge(){
        chatListUsecase.removeBadge()
    }
}
