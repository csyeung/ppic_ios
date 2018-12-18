//
//  PicUserUsecase.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation

protocol PicUserUsecaseProtocol {
    func get(picId: String, completion: @escaping (PicUserEntity) -> Void)
    
    func join(picId: String, completion: @escaping () -> Void)
}

final class PicUserUsecase {
    let repository = PicUserRepository()
}

extension PicUserUsecase: PicUserUsecaseProtocol {
    func get(picId: String, completion: @escaping (PicUserEntity) -> Void) {
        repository.get(picId: picId) { (picUser) in
            completion(picUser)
        }
    }
    
    func join(picId: String, completion: @escaping () -> Void) {
        repository.join(picId: picId, completion: completion)
    }
}
