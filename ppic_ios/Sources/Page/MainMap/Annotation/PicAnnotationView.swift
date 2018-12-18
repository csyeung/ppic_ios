//
// Created by Jonathan YEUNG on 2018/07/12.
// ppic_ios

// 

import UIKit
import Mapbox
import ClusterKit

final class PicAnnotationView: MGLAnnotationView {
    private(set) var picEntity: PicEntity!
    private let user: UserRepository = UserRepository()
    
    init(_ entity: PicEntity, isMyPic: Bool) {
        super.init(reuseIdentifier: entity.id)
        
        self.picEntity = entity
        setupView(isMyPic: isMyPic)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PicAnnotationView {
    private func setupView(isMyPic: Bool) {
        let filePath : String = isMyPic ? "icon_pic_self" : "icon_pic_other"
        let backgroundView = UIImageView(image: UIImage(named: filePath))

        // サイズ設定
        let width = backgroundView.frame.width
        let height = backgroundView.frame.height
        
        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.insertSubview(backgroundView, at: 0)
    }
}
