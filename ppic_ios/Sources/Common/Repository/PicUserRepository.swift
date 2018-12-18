//
//  PicUserRepository.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/12.

//

import Foundation
import Alamofire
import SwiftyJSON

protocol PicUserRepositoryProtocol {
    func get(picId: String, completion: @escaping (PicUserEntity) -> Void)
    
    func join(picId: String, completion: @escaping () -> Void)
}

final class PicUserRepository: BaseRepository {
    
}

extension PicUserRepository: PicUserRepositoryProtocol {
    func get(picId: String, completion: @escaping (PicUserEntity) -> Void) {
        self.getHeaders(completion: { headers in
            let url = self.makeUrl(uri: "pics/\(picId)/users")
            
            Alamofire.request(url, method: .get, encoding: self.encoding, headers: headers).responseJSON { response in
                if let error = response.error {
                    print(error)
                    return
                }
                
                guard let jsonObject = response.result.value else {
                    return
                }
                
                completion(PicUserEntity(root: jsonObject))
            }
        })
    }
    
    func join(picId: String, completion: @escaping () -> Void) {
        self.getHeaders(completion: { headers in
            let url = self.makeUrl(uri: "pics/\(picId)/users")
            
            let now = Date()
            let parameters = ["joinedAt": now.toISO()]
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: self.encoding, headers: headers).responseJSON { response in
                
                // TODO: APIレスポンスが"OK"で、JSONフォーマットとしては不正なのでエラーが出る
                // なので、この箇所はステータスコードの判定を入れる。サーバサイドの修正が好ましい
                if response.response?.statusCode != 200 {
                    if let error = response.error {
                        print(error)
                        return
                    }
                }
                
                completion()
            }
        })
    }
}
