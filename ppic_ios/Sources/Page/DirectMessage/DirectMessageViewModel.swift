//
// Created by Jonathan YEUNG on 2018/07/09.
// ppic_ios

// 

import RxSwift
import JSQMessagesViewController

final class DirectMessageViewModel {
    var messages = [JSQMessage]()

    var chatMessageUsecase = ChatMessageUsecase()
    var chatListUsecase = ChatListUsecase()
    var blockUsecase = BlockUsecase()
    var blockIds: [String] = []
    
    func send(picId: String, content: String, completion: @escaping () -> Void) {
        chatMessageUsecase.send(picId: picId, content: content, completion: completion)
    }

    func observe(picId: String, on: @escaping () -> Void) {
        blockUsecase.observeSingleEvent { (block) in
            self.chatMessageUsecase.observe(picId: picId, on: { (chatMessage) in
                var _messages: [JSQMessage] = []
                
                for data in chatMessage.data {
                    var text = data.content
                    if let userId = data.userId {
                        if block.ids.contains(userId) {
                            text = "ブロック済みユーザーの発言です"
                        }
                    }

                    guard let message = JSQMessage(senderId: data.userId, senderDisplayName: "", date: data.createdAt, text: text) else { return }
                    
                    _messages.append(message)
                }
                
                self.messages = _messages
                
                on()
            })
        }
    }
    
    func read(picId: String) {
        chatListUsecase.read(picId: picId)
    }
}
