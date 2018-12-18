//
// Created by Jonathan YEUNG on 2018/07/12.
// ppic_ios

// 

import Mapbox
import Alamofire
import SwiftyJSON

protocol MapRepositoryProtocol {
    func get(params: [String: Any], zoomLevel: Int, completion: @escaping ([[String: String]], Int, String?) -> Void)
}

final class MapRepository : BaseRepository {
}

extension MapRepository : MapRepositoryProtocol {
    func get(params: [String: Any], zoomLevel: Int, completion: @escaping ([[String: String]], Int, String?) -> Void) {
        self.getHeaders { headers in
            let url = self.makeUrl(uri: "quadkey/\(zoomLevel)")
            
            Alamofire.request(url, method: .post, parameters: params, encoding: self.encoding, headers: headers).responseJSON { response in
                if let _ = response.error {
                    return
                }
                
                guard let value = response.result.value else {
                    return
                }
                
                // TODO: APIレスポンスの値は必ずEntityクラスにセットするようにしたい
                let responseJSON = JSON(value)
                var currentQuadkey: String?

                let quadkeys = responseJSON["features"].arrayValue.map({ (feature) -> String in
                    let quadkey = feature["properties", "quadkey"].stringValue

                    if feature["properties", "current"].boolValue {
                        currentQuadkey = quadkey
                    }

                    return quadkey
                })

                var quadkeysDic = [[String: String]]()
                for quadkey in quadkeys {
                    quadkeysDic.append(["quadkey": quadkey])
                }
                
                completion(quadkeysDic, zoomLevel, currentQuadkey)
            }
        }
    }
    
    func getPics(keys: [[String: String]], zoomLevel: Int, completion: @escaping ([PicEntity]) -> Void) {
        self.getHeaders { headers in
            let url = self.makeUrl(uri: "quadkey/\(zoomLevel)/pics")
            let params: [String: Any] = ["quadkeys": keys]
            
            Alamofire.request(url, method: .post, parameters: params, encoding: self.encoding, headers: headers).responseJSON { response in
                if let _ = response.error {
                    return
                }
                
                guard let value = response.result.value else {
                    return
                }
                
                let responseJSON = JSON(value)
                let entities = responseJSON["quadkeys"].arrayValue

                var picEntities = [PicEntity]()
                
                for entity in entities {
//                    let quadkey = entity["quadkey"].stringValue
//                    var picsPerQuadkey = entity["pics"].arrayValue.map {
                    let picsPerQuadkey = entity["pics"].arrayValue.map {
                        PicEntity(root: $0)
                    }
                    
                    // ぴっくの表示数
                    picEntities.append(contentsOf: picsPerQuadkey)
                    // !!!: 仕様要確認
//                    for _ in 0..<2 {
//                        if picsPerQuadkey.count > 0 {
//                            let picEntity = picsPerQuadkey.removeFirst()
//                            picEntities.append(picEntity)
//                        }
//                    }

                    // TODO: 履歴（一旦処理しません）
                }
                
                completion(picEntities)
            }
        }
    }
}
