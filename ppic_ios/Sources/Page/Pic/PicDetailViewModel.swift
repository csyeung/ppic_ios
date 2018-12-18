//
// Created by Jonathan YEUNG on 2018/07/11.
// ppic_ios

// 

import Foundation
import RxSwift

final class PicDetailViewModel {
    private let picUsecase = PicUsecase()
    private let userUsecase = UserUsecase()
    private let picUserUsecase = PicUserUsecase()
    
    let ownerUid = Variable("")
    let ownerDisplayName = Variable("")
    let ownerPhotoURL = Variable("")
    let title = Variable("")
    let photoURL = Variable("")
    let participantsNumber = Variable("")
    let isMine = Variable(false)
    let picUser: Variable<PicUserEntity?> = Variable(nil)
    let state: Variable<PicEntity.State> = Variable(.unknown)
    let id = Variable("")
    
    func load(id: String) {
        picUsecase.get(id: id, completion: { (pic) in
            self.id.value = pic.id
            self.title.value = pic.title
            self.photoURL.value = pic.photoURL
            self.participantsNumber.value = pic.participantsNumber.description
            self.state.value = pic.state

            if let owner = pic.owner {
                self.ownerUid.value = owner.uid
                self.ownerDisplayName.value = owner.displayName
                self.ownerPhotoURL.value = owner.photoURL
            }
            
            self.userUsecase.getMyProfile(completion: { (user) in
                if let picId = user.currentPic?.id {
                    self.isMine.value = pic.id == picId
                }
            })
        })
        
        picUserUsecase.get(picId: id) { (picUser) in
            self.picUser.value = picUser
        }
    }
    
    func join(id: String, completion: @escaping () -> Void) {
        picUserUsecase.join(picId: id, completion: completion)
    }
    
    func pic(completion: @escaping (PicEntity) -> Void) {
        picUsecase.get(id: self.id.value, completion: { (pic) in
            completion(pic)
        })
    }
}
