//
// Created by Jonathan YEUNG on 2018/07/24.
// ppic_ios

// 

import RxSwift
import DIKit
import SVProgressHUD

protocol SettingUsecaseProtocol {
    var photoUrl: Observable<String> { get }
    var displayName: Observable<String> { get }
    var bio: Observable<String> { get }
    
    func save(displayName: String, bio: String, photoImage: UIImage?, completion: @escaping (UserEntity) -> Void)
}

final class SettingUsecase: Injectable {
    struct Dependency {
        let photoUrl: String
        let displayName: String
        let bio: String
    }
    
    private(set) var _photoUrl: BehaviorSubject<String>
    private(set) var _displayName: BehaviorSubject<String>
    private(set) var _bio: BehaviorSubject<String>
    
    // TODO: 正しい形に修正
    private let userUsecase = UserUsecase()
    
    init(dependency: Dependency) {
        self._photoUrl = .init(value: dependency.photoUrl)
        self._displayName = .init(value: dependency.displayName)
        self._bio = .init(value: dependency.bio)
        
        initialize()
    }

    private func initialize() {
        SVProgressHUD.show()
        
        userUsecase.getMyProfile() { [unowned self] user in
            self._photoUrl.onNext(user.photoURL)
            self._displayName.onNext(user.displayName)
            self._bio.onNext(user.bio)
            
            SVProgressHUD.dismiss()
        }
    }
}

extension SettingUsecase: SettingUsecaseProtocol {
    var photoUrl: Observable<String> {
        return _photoUrl.asObservable()
    }
    
    var displayName: Observable<String> {
        return _displayName.asObservable()
    }
    
    var bio: Observable<String> {
        return _bio.asObservable()
    }

    func save(displayName: String, bio: String, photoImage: UIImage?, completion: @escaping (UserEntity) -> Void) {
        SVProgressHUD.show()
        
        userUsecase.updateProfile(displayName: displayName, bio: bio, photoImage: photoImage) { user in
            SVProgressHUD.dismiss()
            completion(user)
        }
    }
}
