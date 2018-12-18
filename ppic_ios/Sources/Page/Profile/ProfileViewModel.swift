//
// Created by Jonathan YEUNG on 2018/07/09.
// ppic_ios

// 

import UIKit
import RxSwift
import DIKit
import RxCocoa

protocol ProfileViewModelProtocol {
    var uid: String { get }
    var profileData: Observable<(String, String, String)> { get }
    var isMine: Bool { get }
}

final class ProfileViewModel : Injectable {
    struct Dependency {
        let profileUsecase: ProfileUsecaseProtocol
    }
    
    let profileUsecase: ProfileUsecaseProtocol
    
    private let _uid: String
    private let _isMine: Bool
    private let _profileData: BehaviorSubject<(String, String, String)> = .init(value: ("", "", ""))
    private let disposeBag: DisposeBag = .init()
    
    init(dependency: Dependency) {
        self.profileUsecase = dependency.profileUsecase
        self._uid = dependency.profileUsecase.uid
        self._isMine = dependency.profileUsecase.isMine
        
        bindUsecase()
    }
}

extension ProfileViewModel {
    private func bindUsecase() {
        Observable.combineLatest(profileUsecase.photoUrl, profileUsecase.displayName, profileUsecase.bio)
            .bind(to: profileUsecaseObserver)
            .disposed(by: disposeBag)
    }
}

private extension ProfileViewModel {
    private func profileUsecaseEventHandler(_ event: Event<(String, String, String)>) {
        _profileData.on(event)
    }
    
    var profileUsecaseObserver: AnyObserver<(String, String, String)> {
        return .init(eventHandler: profileUsecaseEventHandler)
    }
}

extension ProfileViewModel: ProfileViewModelProtocol {
    var uid: String {
        return _uid
    }
    
    var profileData: Observable<(String, String, String)> {
        return _profileData.asObservable()
    }
    
    var isMine: Bool {
        return _isMine
    }
}
