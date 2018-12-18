//
// Created by Jonathan YEUNG on 2018/07/24.
// ppic_ios

// 

import RxSwift
import DIKit
import SVProgressHUD

protocol ProfileUsecaseProtocol {
    var uid: String { get }
    var photoUrl: Observable<String> { get }
    var displayName: Observable<String> { get }
    var bio: Observable<String> { get }
    var isMine: Bool { get }
}

final class ProfileUsecase: Injectable {
    struct Dependency {
        let uid: String
        let photoUrl: String
        let displayName: String
        let bio: String
        let isMine: Bool
    }
    
    private(set) var _uid: String
    private(set) var _photoUrl: BehaviorSubject<String>
    private(set) var _displayName: BehaviorSubject<String>
    private(set) var _bio: BehaviorSubject<String>
    private(set) var _isMine: Bool
    
    init(dependency: Dependency) {
        self._uid = dependency.uid
        self._photoUrl = .init(value: dependency.photoUrl)
        self._displayName = .init(value: dependency.displayName)
        self._bio = .init(value: dependency.bio)
        self._isMine = dependency.isMine
        
        initialize()
    }

    private func initialize() {
        SVProgressHUD.show()

        let userRepository = UserRepository()
        
        userRepository.find(uid: self._uid) { [unowned self] user in
            self._photoUrl.onNext(user.photoURL)
            self._displayName.onNext(user.displayName)
            self._bio.onNext(user.bio)
            
            SVProgressHUD.dismiss()
        }
        
        userRepository.findMine { [unowned self] user in
            self._isMine = user.uid == self._uid
        }
    }
}

extension ProfileUsecase: ProfileUsecaseProtocol {
    var uid: String {
        return _uid
    }
    
    var photoUrl: Observable<String> {
        return _photoUrl.asObservable()
    }
    
    var displayName: Observable<String> {
        return _displayName.asObservable()
    }
    
    var bio: Observable<String> {
        return _bio.asObservable()
    }
    
    var isMine: Bool {
        return _isMine
    }
}
