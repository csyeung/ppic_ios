//
//  Resolver.swift
//  Generated by dikitgen.
//

import ClusterKit
import CoreLocation
import CropViewController
import DIKit
import Foundation
import Kingfisher
import Mapbox
import NotAutoLayout
import RxCocoa
import RxSwift
import SVProgressHUD
import UIKit

extension AppResolver {

    func injectToMainMapController(_ mainMapController: MainMapController, mapStyleURL: URL?, defaultCellSize: CGFloat, defaultZoomLevel: Double, maxZoomLevel: Double, mapRefreshPeriod: Int) -> Void {
        let mainMapViewModelProtocol = resolveMainMapViewModelProtocol()
        mainMapController.dependency = MainMapController.Dependency(mapStyleURL: mapStyleURL, defaultCellSize: defaultCellSize, defaultZoomLevel: defaultZoomLevel, maxZoomLevel: maxZoomLevel, mapRefreshPeriod: mapRefreshPeriod, viewModel: mainMapViewModelProtocol)
    }

    func injectToPostPicController(_ postPicController: PostPicController, keyboard: CGFloat, keyboardiPad: CGFloat, photoWidth: CGFloat, defaultPlace: CLLocationCoordinate2D, titleLimit: Int) -> Void {
        postPicController.dependency = PostPicController.Dependency(keyboard: keyboard, keyboardiPad: keyboardiPad, photoWidth: photoWidth, defaultPlace: defaultPlace, titleLimit: titleLimit)
    }

    func injectToProfileViewController(_ profileViewController: ProfileViewController, layoutHeight: CGFloat, uid: String) -> Void {
        let profileViewModelProtocol = resolveProfileViewModelProtocol(uid: uid)
        profileViewController.dependency = ProfileViewController.Dependency(layoutHeight: layoutHeight, viewModel: profileViewModelProtocol)
    }

    func injectToSettingController(_ settingController: SettingController, menuHeader: CGFloat) -> Void {
        let settingViewModelProtocol = resolveSettingViewModelProtocol()
        settingController.dependency = SettingController.Dependency(menuHeader: menuHeader, viewModel: settingViewModelProtocol)
    }

    func resolveMainMapViewModel() -> MainMapViewModel {
        let mapUsecaseProtocol = resolveMapUsecaseProtocol()
        return MainMapViewModel(dependency: .init(mapUsecase: mapUsecaseProtocol))
    }

    func resolveMainMapViewModelProtocol() -> MainMapViewModelProtocol {
        return provideMapViewModelProtocol()
    }

    func resolveMapUsecase(defaultPlace: CLLocationCoordinate2D, defaultZoomLevel: Double, accessToken: String) -> MapUsecase {
        return MapUsecase(dependency: .init(defaultPlace: defaultPlace, defaultZoomLevel: defaultZoomLevel, accessToken: accessToken))
    }

    func resolveMapUsecaseProtocol() -> MapUsecaseProtocol {
        return provideMapUsecaseProtocol()
    }

    func resolveProfileUsecase(uid: String, photoUrl: String, displayName: String, bio: String, isMine: Bool) -> ProfileUsecase {
        return ProfileUsecase(dependency: .init(uid: uid, photoUrl: photoUrl, displayName: displayName, bio: bio, isMine: isMine))
    }

    func resolveProfileUsecaseProtocol(uid: String) -> ProfileUsecaseProtocol {
        return provideProfileUsecaseProtocol(uid: uid)
    }

    func resolveProfileViewModel(uid: String) -> ProfileViewModel {
        let profileUsecaseProtocol = resolveProfileUsecaseProtocol(uid: uid)
        return ProfileViewModel(dependency: .init(profileUsecase: profileUsecaseProtocol))
    }

    func resolveProfileViewModelProtocol(uid: String) -> ProfileViewModelProtocol {
        return provideProfileViewModelProtocol(uid: uid)
    }

    func resolveSettingUsecase(photoUrl: String, displayName: String, bio: String) -> SettingUsecase {
        return SettingUsecase(dependency: .init(photoUrl: photoUrl, displayName: displayName, bio: bio))
    }

    func resolveSettingUsecaseProtocol() -> SettingUsecaseProtocol {
        return provideSettingUsecaseProtocol()
    }

    func resolveSettingViewModel() -> SettingViewModel {
        let settingUsecaseProtocol = resolveSettingUsecaseProtocol()
        return SettingViewModel(dependency: .init(settingUsecase: settingUsecaseProtocol))
    }

    func resolveSettingViewModelProtocol() -> SettingViewModelProtocol {
        return provideSettingViewModelProtocol()
    }

}

