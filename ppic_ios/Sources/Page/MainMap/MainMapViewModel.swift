//
//  MainMapViewModel.swift
//  ppic_ios
//
//  Created by 史翔新 on 2018/07/07.

//

import Foundation
import CoreLocation
import RxSwift
import DIKit

protocol MainMapViewModelProtocol {
	var centerAndZoomLevel: Observable<(CLLocationCoordinate2D, Double)> { get }
}

final class MainMapViewModel: Injectable {
	
	struct Dependency {
		let mapUsecase: MapUsecaseProtocol
	}
	
	let mapUsecase: MapUsecaseProtocol
	
	private let _centerAndZoomLevel: BehaviorSubject<(CLLocationCoordinate2D, Double)> = .init(value: (.init(), 0))
	
	private let disposeBag: DisposeBag = .init()
	
	init(dependency: Dependency) {
		self.mapUsecase = dependency.mapUsecase
		bindUsecase()
	}
	
}

extension MainMapViewModel {
	
	private func bindUsecase() {
		
		Observable.combineLatest(mapUsecase.defaultPlace,
								 mapUsecase.defaultZoomLevel)
			.bind(to: mapUsecaseObserver)
			.disposed(by: disposeBag)
		
	}
	
}

private extension MainMapViewModel {
	
	private func mapUsecaseEventHandler(_ event: Event<(CLLocationCoordinate2D, Double)>) {
		_centerAndZoomLevel.on(event)
	}
	
	var mapUsecaseObserver: AnyObserver<(CLLocationCoordinate2D, Double)> {
		return .init(eventHandler: mapUsecaseEventHandler)
	}
	
}

extension MainMapViewModel: MainMapViewModelProtocol {
	
	var centerAndZoomLevel: Observable<(CLLocationCoordinate2D, Double)> {
		return _centerAndZoomLevel.asObservable()
	}
	
}
