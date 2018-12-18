//
//  UserUsecase.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/09.

//

import Foundation
import UIKit
import Firebase
import Alamofire

protocol UserUsecaseProtocol {
    func register(displayName: String, photoImage: UIImage?, completion: @escaping (UserEntity) -> Void)

    func getProfile(uid: String, completion: @escaping (UserEntity) -> Void)
    
    func getMyProfile(completion: @escaping (UserEntity) -> Void)
    
    func updateProfile(displayName: String, bio: String, photoImage: UIImage?, completion: @escaping (UserEntity) -> Void)
}

final class UserUsecase: BaseUsecase {
    let repository = UserRepository()
}

extension UserUsecase: UserUsecaseProtocol {
    func register(displayName: String, photoImage: UIImage?, completion: @escaping (UserEntity) -> Void) {

        var photo: String? = nil

        if let photoImage = photoImage {
            photo = photoImage.base64PNG()
        }

        repository.create(displayName: self.trim(string: displayName), photo: photo) { (user) in
            completion(user)
        }
    }

    func getProfile(uid: String, completion: @escaping (UserEntity) -> Void) {
        let repository = UserRepository()
        
        repository.find(uid: uid, completion: completion)
    }
    
    func getMyProfile(completion: @escaping (UserEntity) -> Void) {
        repository.findMine(completion: completion)
    }

    func updateProfile(displayName: String, bio: String, photoImage: UIImage?, completion: @escaping (UserEntity) -> Void) {
        let repository = UserRepository()
        
        var photo: String? = nil
        
        if let photoImage = photoImage {
            photo = photoImage.base64PNG()
        }

        repository.findMine { (user) in
            repository.update(uid: user.uid, displayName: self.trim(string: displayName), bio: self.trim(string: bio), photo: photo) { (user) in
                completion(user)
            }
        }
    }
}
