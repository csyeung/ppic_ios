//
//  PicUsecase.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/10.

//

import UIKit
import Mapbox

protocol PicUsecaseProtocol {
    func get(id: String, completion: @escaping (PicEntity) -> Void)

    func post(title: String, geo: CLLocationCoordinate2D, photoImage: UIImage?, completion: @escaping (PicEntity) -> Void)
    
    func close(id: String, completion: @escaping (PicEntity) -> Void)
}

final class PicUsecase: BaseUsecase {
    let repository = PicRepository()
}

extension PicUsecase: PicUsecaseProtocol {
    func get(id: String, completion: @escaping (PicEntity) -> Void) {
        repository.find(id: id) { (pic) in
            completion(pic)
        }
    }

    func post(title: String, geo: CLLocationCoordinate2D, photoImage: UIImage?, completion: @escaping (PicEntity) -> Void) {
        var photo: String? = nil
        
        if let photoImage = photoImage {
            photo = photoImage.base64JPEG()
        }

        repository.create(title: self.trim(string: title), geo: geo, photo: photo) { (pic) in
            completion(pic)
        }
    }
    
    func close(id: String, completion: @escaping (PicEntity) -> Void) {
        repository.close(id: id) { (pic) in
            completion(pic)
        }
    }
}
