//
//  UserRepository.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/09.

//

import Foundation
import Firebase
import Alamofire

protocol UserRepositoryProtocol {
    func find(uid: String, completion: @escaping (UserEntity) -> Void)

    func findMine(completion: @escaping (UserEntity) -> Void)

    func findMineForceRefresh(completion: @escaping (UserEntity) -> Void)

    func create(displayName: String, photo: String?, completion: @escaping (UserEntity) -> Void)
    
    func update(uid: String, displayName: String, bio: String, photo: String?, completion: @escaping (UserEntity) -> Void)
}

final class UserRepository: BaseRepository {
    private let myUserKeyName = "myUser"
}

extension UserRepository: UserRepositoryProtocol {
    func find(uid: String, completion: @escaping (UserEntity) -> Void) {
        self.getHeaders(completion: { headers in
            let url = self.makeUrl(uri: "users/" + uid)
            
            Alamofire.request(url, method: .get, encoding: self.encoding, headers: headers).responseJSON { response in
                if let error = response.error {
                    print(error)
                    return
                }

                guard let jsonObject = response.result.value else {
                    return
                }
                
                completion(UserEntity(root: jsonObject))
            }
        })
    }
    
    func findMineForceRefresh(completion: @escaping (UserEntity) -> Void) {
        removeCache()

        return self.findMine(completion: completion)
    }

    func findMine(completion: @escaping (UserEntity) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        if let jsonObject = getCache() {
            return completion(UserEntity(root: jsonObject))
        }
        
        self.getHeaders(completion: { headers in
            let url = self.makeUrl(uri: "users/" + user.uid)
            
            Alamofire.request(url, method: .get, encoding: self.encoding, headers: headers).responseJSON { response in
                if let error = response.error {
                    print(error)
                    return
                }

                guard let jsonObject = response.result.value else {
                    return
                }
                
                self.setCache(jsonObject: jsonObject)

                completion(UserEntity(root: jsonObject))
            }
        })
    }

    func create(displayName: String, photo: String?, completion: @escaping (UserEntity) -> Void) {
        Auth.auth().signInAnonymously() { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let user = result?.user else {
                return
            }
            
            self.getHeaders(completion: { headers in
                let url = self.makeUrl(uri: "users")
                
                var parameters = ["uid": user.uid, "displayName": displayName, "notificationToken": Messaging.messaging().fcmToken ?? ""]
                
                if let photo = photo {
                    parameters["photo"] = photo
                }
                
                // https://firebase.google.com/docs/cloud-messaging/ios/client?hl=ja
                Alamofire.request(url, method: .post, parameters: parameters, encoding: self.encoding, headers: headers).responseJSON { response in
                    
                    if let error = response.error {
                        print(error)
                        return
                    }
                    
                    guard let jsonObject = response.result.value else {
                        return
                    }
                    
                    self.setCache(jsonObject: jsonObject)
                    
                    completion(UserEntity(root: jsonObject))
                }
            })
        }
    }

    func update(uid: String, displayName: String, bio: String, photo: String?, completion: @escaping (UserEntity) -> Void) {
        self.getHeaders(completion: { headers in
            let url = self.makeUrl(uri: "users/" + uid)
            
            var parameters = ["displayName": displayName, "bio": bio, "notificationToken": Messaging.messaging().fcmToken ?? ""]
            
            if let photo = photo {
                parameters["photo"] = photo
            }
            
            Alamofire.request(url, method: .patch, parameters: parameters, encoding: self.encoding, headers: headers).responseJSON { response in
                if let error = response.error {
                    print(error)
                    return
                }

                guard let jsonObject = response.result.value else {
                    return
                }

                self.setCache(jsonObject: jsonObject)

                completion(UserEntity(root: jsonObject))
            }
        })
    }
    
    private func setCache(jsonObject: Any) {
        UserDefaults.standard.set(jsonObject, forKey: self.myUserKeyName)
        UserDefaults.standard.synchronize()
    }
    
    private func removeCache() {
        UserDefaults.standard.removeObject(forKey: self.myUserKeyName)
        UserDefaults.standard.synchronize()
    }
    
    private func getCache() -> Any? {
        return UserDefaults.standard.object(forKey: self.myUserKeyName)
    }
}
