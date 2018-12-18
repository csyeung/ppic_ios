//
//  BlockUsecase.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation
import Firebase

protocol BlockUsecaseProtocol {
    func observeSingleEvent(on: @escaping (BlockEntity) -> Void)
    
    func block(userId: String)
    
    func unblock(userId: String)
}

final class BlockUsecase {
    private let repository = BlockRepository()
}

extension BlockUsecase: BlockUsecaseProtocol {
    func observeSingleEvent(on: @escaping (BlockEntity) -> Void) {
        repository.observeSingleEvent { (snapshot) in
            on(BlockEntity(root: snapshot))
        }
    }
    
    func block(userId: String) {
        repository.create(userId: userId)
    }
    
    func unblock(userId: String) {
        repository.delete(userId: userId)
    }
}
