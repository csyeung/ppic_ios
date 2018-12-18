//
//  AppResolver.swift
//  ppic_ios
//
//  Created by 史翔新 on 2018/07/07.

//

import Foundation
import CoreLocation
import DIKit
import UIKit

protocol AppResolver: Resolver {
    // Usecases
    func provideMapUsecaseProtocol() -> MapUsecaseProtocol
    func provideSettingUsecaseProtocol() -> SettingUsecaseProtocol
    func provideProfileUsecaseProtocol(uid: String) -> ProfileUsecaseProtocol
	
    // ViewModels
    func provideMapViewModelProtocol() -> MainMapViewModelProtocol
    func provideSettingViewModelProtocol() -> SettingViewModelProtocol
    func provideProfileViewModelProtocol(uid: String) -> ProfileViewModelProtocol
    
    // ViewControllers
    func inject(toMainMapController controller: MainMapController)
    func inject(toPostPicController controller: PostPicController)
    func inject(toSettingController controller: SettingController)
    func inject(toProfileViewController controller: ProfileViewController, uid: String)
}

final class ProductionAppResolver: AppResolver {
    private let shibuya: CLLocationCoordinate2D = .init(latitude: 35.658313, longitude: 139.701657)

	// Declare an instance as property so it can be used like a singleton
	private lazy var mapUsecase: MapUsecase = {
		let zoomLevel: Double = 17
		let accessToken = "pk.eyJ1IjoiZmxpcG1hcCIsImEiOiJjamZwa25qMDYya296MnFxZm40b3ZodHBsIn0.YzQ5wc_Ovje74z71qyESuQ"
		
		let dependency: MapUsecase.Dependency = .init(defaultPlace: shibuya,
													  defaultZoomLevel: zoomLevel,
													  accessToken: accessToken)
		let mapUsecase: MapUsecase = .init(dependency: dependency)
		
		return mapUsecase
	}()
    
    private lazy var settingUsecase: SettingUsecase = {
        let dependency: SettingUsecase.Dependency = .init(photoUrl: "",
                                                          displayName: "",
                                                          bio: "")
        
        let settingUsecase: SettingUsecase = .init(dependency: dependency)
        return settingUsecase
    }()
    
	func provideMapUsecaseProtocol() -> MapUsecaseProtocol {
		return mapUsecase
	}
    
    func provideSettingUsecaseProtocol() -> SettingUsecaseProtocol {
        return settingUsecase
    }
    
    func provideProfileUsecaseProtocol(uid: String) -> ProfileUsecaseProtocol {
        let dependency: ProfileUsecase.Dependency = .init(uid: uid,
                                                          photoUrl: "",
                                                          displayName: "",
                                                          bio: "",
                                                          isMine: false)
        
        let profileUsecase: ProfileUsecase = .init(dependency: dependency)
        return profileUsecase
    }
    
	func provideMapViewModelProtocol() -> MainMapViewModelProtocol {
		return resolveMainMapViewModel()
	}
    
    func provideSettingViewModelProtocol() -> SettingViewModelProtocol {
        return resolveSettingViewModel()
    }

    func provideProfileViewModelProtocol(uid: String) -> ProfileViewModelProtocol {
        return resolveProfileViewModel(uid: uid)
    }

	func inject(toMainMapController controller: MainMapController) {
		let mapStyleURL = URL(string: "mapbox://styles/flipmap/cjjsfq52u2e4y2rnw1jwg172q?optimize=true")
        let cellSize: CGFloat = 300
        let zoomLevel: Double = 17
        let maxZoom: Double = 20
        let mapRefreshPeriod: Int = 30
        let viewModel = resolveMainMapViewModelProtocol()
		let dependency: MainMapController.Dependency = .init(mapStyleURL: mapStyleURL,
                                                             defaultCellSize: cellSize,
                                                             defaultZoomLevel: zoomLevel,
                                                             maxZoomLevel: maxZoom,
                                                             mapRefreshPeriod: mapRefreshPeriod,
															 viewModel: viewModel)
		controller.dependency = dependency
	}
    
    func inject(toPostPicController controller: PostPicController) {
        let keyboardAdjust : CGFloat = 16
        let keyboardAdjustiPad : CGFloat = 64
        let maxPhotoWidth : CGFloat = 414
        let titleLimit: Int = 30
        
        let dependency: PostPicController.Dependency = .init(keyboard: keyboardAdjust,
                                                             keyboardiPad: keyboardAdjustiPad,
                                                             photoWidth: maxPhotoWidth,
                                                             defaultPlace: shibuya,
                                                             titleLimit: titleLimit)
        controller.dependency = dependency
    }
    
    func inject(toSettingController controller: SettingController) {
        let menuHeaderSpace : CGFloat = 30
        let viewModel = resolveSettingViewModelProtocol()
        
        let dependency: SettingController.Dependency = .init(menuHeader: menuHeaderSpace,
                                                             viewModel: viewModel)
        controller.dependency = dependency
    }
    
    func inject(toProfileViewController controller: ProfileViewController, uid: String) {
        let layoutHeight : CGFloat = 450
        let viewModel = resolveProfileViewModelProtocol(uid: uid)
        
        let dependency: ProfileViewController.Dependency = .init(layoutHeight: layoutHeight,
                                                                 viewModel: viewModel)
        controller.dependency = dependency
    }
}
