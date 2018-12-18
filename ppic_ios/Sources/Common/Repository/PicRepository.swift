//
//  PicRepository.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/10.

//

import Foundation
import Alamofire
import Mapbox

protocol PicRepositoryProtocol {
    func find(id: String, completion: @escaping (PicEntity) -> Void)
    
    func create(title: String, geo: CLLocationCoordinate2D, photo: String?, completion: @escaping (PicEntity) -> Void)

    func close(id: String, completion: @escaping (PicEntity) -> Void)
}

final class PicRepository: BaseRepository {
    // userRepository.findMine()で用いるキャッシュのクリアに用いる
    let userRepository = UserRepository()
}

extension PicRepository: PicRepositoryProtocol {
    func find(id: String, completion: @escaping (PicEntity) -> Void) {
        self.getHeaders(completion: { headers in
            let url = self.makeUrl(uri: "pics/" + id)
            
            Alamofire.request(url, method: .get, encoding: self.encoding, headers: headers).responseJSON { response in
                if let error = response.error {
                    print(error)
                    return
                }
                
                guard let jsonObject = response.result.value else {
                    return
                }
                
                completion(PicEntity(root: jsonObject))
            }
        })
    }
    
    func create(title: String, geo: CLLocationCoordinate2D, photo: String?, completion: @escaping (PicEntity) -> Void) {
        self.getHeaders(completion: { headers in
            let url = self.makeUrl(uri: "pics")
            
            var parameters: [String : Any] = ["title": title, "geo": ["latitude": geo.latitude, "longitude": geo.longitude]]
            
            if let photo = photo {
                parameters["photo"] = photo
            }
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: self.encoding, headers: headers).responseJSON { response in
                if let error = response.error {
                    print(error)
                    return
                }
                
                guard let jsonObject = response.result.value else {
                    return
                }

                self.userRepository.findMineForceRefresh(completion: { _ in
                    completion(PicEntity(root: jsonObject))
                })
            }
        })
    }
    
    func close(id: String, completion: @escaping (PicEntity) -> Void) {
        self.getHeaders(completion: { headers in
            let url = self.makeUrl(uri: "pics/" + id)
            
            let parameters: [String : Any] = ["isClosed": true]
            
            Alamofire.request(url, method: .put, parameters: parameters, encoding: self.encoding, headers: headers).responseJSON { response in
                if let error = response.error {
                    print(error)
                    return
                }
                
                guard let jsonObject = response.result.value else {
                    return
                }
                
                self.userRepository.findMineForceRefresh(completion: { _ in
                    completion(PicEntity(root: jsonObject))
                })
            }
        })
    }
}
