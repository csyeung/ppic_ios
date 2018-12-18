//
//  SettingViewModel.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/10.

//

import Foundation
import RxSwift
import UIKit
import DIKit

protocol SettingViewModelProtocol {
    var settingData: Observable<(String, String, String)> { get }
    func save(displayName: String, bio: String, photoImage: UIImage?, completion: @escaping (UserEntity) -> Void)
}

final class SettingViewModel : Injectable {
    struct Dependency {
        let settingUsecase: SettingUsecaseProtocol
    }
    
    let settingUsecase: SettingUsecaseProtocol

    private let _settingData: BehaviorSubject<(String, String, String)> = .init(value: ("", "", ""))
    
    private let disposeBag: DisposeBag = .init()
    
    init(dependency: Dependency) {
        self.settingUsecase = dependency.settingUsecase
        bindUsecase()
    }
}

extension SettingViewModel {
    private func bindUsecase() {
        Observable.combineLatest(settingUsecase.photoUrl, settingUsecase.displayName, settingUsecase.bio)
            .bind(to: settingUsecaseObserver)
            .disposed(by: disposeBag)
    }
}

private extension SettingViewModel {
    private func settingUsecaseEventHandler(_ event: Event<(String, String, String)>) {
        _settingData.on(event)
    }
    
    var settingUsecaseObserver: AnyObserver<(String, String, String)> {
        return .init(eventHandler: settingUsecaseEventHandler)
    }
}

extension SettingViewModel : SettingViewModelProtocol {
    var settingData: Observable<(String, String, String)> {
        return _settingData.asObservable()
    }
    
    func save(displayName: String, bio: String, photoImage: UIImage?, completion: @escaping (UserEntity) -> Void) {
        settingUsecase.save(displayName: displayName, bio: bio, photoImage: photoImage, completion: completion)
    }
}
