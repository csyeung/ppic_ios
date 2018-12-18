//
// Created by Jonathan YEUNG on 2018/07/12.
// ppic_ios

// 

import Mapbox

final class PicAnnotation: MGLPointAnnotation {
    var picEntity: PicEntity
    var isMyPic: Bool
    
    init(_ entity: PicEntity, isMyPic: Bool = false) {
        self.picEntity = entity
        self.isMyPic = isMyPic
        
        super.init()
        self.coordinate = CLLocationCoordinate2DMake(entity.geo.latitude, entity.geo.longitude)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
