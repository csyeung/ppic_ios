//
//  MapUsecase.swift
//  ppic_ios
//
//  Created by RN−178 on 2018/07/04.

//

import Mapbox
import RxSwift
import DIKit

protocol MapUsecaseProtocol {
	var defaultPlace: Observable<CLLocationCoordinate2D> { get }
	var defaultZoomLevel: Observable<Double> { get }
}

final class MapUsecase: Injectable {
	
	struct Dependency {
		let defaultPlace: CLLocationCoordinate2D
		let defaultZoomLevel: Double
		let accessToken: String
	}
	
	private let _defaultPlace: BehaviorSubject<CLLocationCoordinate2D>
	private let _defaultZoomLevel: BehaviorSubject<Double>
	
	private let accessToken: String
	
	init(dependency: Dependency) {
		
		self._defaultPlace = .init(value: dependency.defaultPlace)
		self._defaultZoomLevel = .init(value: dependency.defaultZoomLevel)
		self.accessToken = dependency.accessToken
		
		initialize()
		
	}
	
	private func initialize() {
		
		MGLAccountManager.accessToken = accessToken
		
	}
	
}

extension MapUsecase: MapUsecaseProtocol {
	
	var defaultPlace: Observable<CLLocationCoordinate2D> {
		return _defaultPlace.asObservable()
	}
	
	var defaultZoomLevel: Observable<Double> {
		return _defaultZoomLevel.asObservable()
	}
	
}
