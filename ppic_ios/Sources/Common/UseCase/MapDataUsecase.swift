//
// Created by Jonathan YEUNG on 2018/07/12.
// ppic_ios

// 

import Mapbox

protocol MapDataUsecaseProtocol {
    func getMapInfos(lt: CLLocationCoordinate2D, rt: CLLocationCoordinate2D, rb: CLLocationCoordinate2D, lb: CLLocationCoordinate2D, current: CLLocationCoordinate2D, zoomLevel: Double, completion: @escaping ([PicEntity]?) -> Void)
    
}

final class MapDataUsecase {
    let repository = MapRepository()
}

// DIの使い方がわからないので、暫定ここでデータ取得処理します。
extension MapDataUsecase : MapDataUsecaseProtocol {
    func getMapInfos(lt: CLLocationCoordinate2D, rt: CLLocationCoordinate2D, rb: CLLocationCoordinate2D, lb: CLLocationCoordinate2D, current: CLLocationCoordinate2D, zoomLevel: Double, completion: @escaping ([PicEntity]?) -> Void) {
        // ズームレベル 14 以下は表示しません
        if zoomLevel < 14 {
            completion(nil)
            return
        }

        // 必要なパラメータ整理
        let level = getQuadkeyLevel(by: zoomLevel)
        let pointLT = ["latitude": lt.latitude, "longitude": lt.longitude]
        let pointRT = ["latitude": rt.latitude, "longitude": rt.longitude]
        let pointRB = ["latitude": rb.latitude, "longitude": rb.longitude]
        let pointLB = ["latitude": lb.latitude, "longitude": lb.longitude]
        let pointcurrent = ["latitude": current.latitude, "longitude": current.longitude]
        let pointArray = [
            pointLT, pointRT, pointRB, pointLB
        ]
        let params: [String: Any] = ["corners": pointArray, "current": pointcurrent]

        self.repository.get(params: params, zoomLevel: level) { [weak self] quadkeysDic, zoomLevel, currentQuadkey in
            
            if quadkeysDic.count == 0 {
                completion(nil)
                return
            }
            
            if let currentQuadkey = currentQuadkey {
                AnalyticsEventUtility.shared.send(name: .completeLoadMap, picId: nil, picOwnerUid: nil, optionalParameters: [
                    "current_quadkey": currentQuadkey,
                    "zoom_level": zoomLevel
                ])
            }

            self?.repository.getPics(keys: quadkeysDic, zoomLevel: level) { entities in
                completion(entities)
            }
        }
    }
}

extension MapDataUsecase {
    private func getQuadkeyLevel(by zoomLevel: Double) -> Int {
        let quadLevel = zoomLevel < 14 ? 14 : Int(round(zoomLevel + 1))
        return quadLevel
    }
}
