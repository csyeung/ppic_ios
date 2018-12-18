//
//  BaseRepository.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/09.

//

import Firebase
import Alamofire

class BaseRepository {
    let encoding = JSONEncoding.default
    
    func makeUrl(uri: String) -> String {
        return EnvUtility.apiEndPoint + uri
    }
    
    func getHeaders(completion: @escaping ([String: String]) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        user.getIDToken { (idToken, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let idToken = idToken else {
                return
            }

            completion(self.makeHeaders(idToken: idToken))
        }
    }

    private func makeHeaders(idToken: String) -> [String: String] {
        return [
            "Authorization": "Bearer \(idToken)",
            "Accept": "application/vnd.goa.error",
            "Content-Type": "application/json",
        ]
    }
}
