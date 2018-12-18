//
//  OnBoardingShareController.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/18.

//

import UIKit
import CoreLocation

final class OnBoardingShareController: UIViewController, BaseOnBoardingStub {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var bgImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var bgImageViewBottomConstraint: NSLayoutConstraint!

    private let slug = "share"

    private let locationManager = CLLocationManager()
    private var authorizationStatusChecked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        AnalyticsEventUtility.shared.send(name: .openOnBoardingShare)
    }
}

// MARK: Main function
extension OnBoardingShareController {
    private func setupView() {
        bgImageViewTopConstraint.constant -= UIApplication.shared.statusBarFrame.size.height
        bgImageView.image = UIImage(named: getBgImageName(slug: slug))
        buttonBottomConstraint.constant += getBottomMargin()
        
        // TODO: 画像の文字がボタンに被らないようにするための応急処置
        if AppUtility.isIPad() {
            bgImageViewBottomConstraint.constant += 20
        }
    }
    
    private func pushNext() {
        self.appDelegate?.transitionDelegate?.viewController(self, needsTransitionWith: OnBoardingPage.next)
    }
}

// MARK: IBAction
extension OnBoardingShareController {
    @IBAction func doNext() {
        if authorizationStatusChecked {
            pushNext()
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            pushNext()
        case .authorizedAlways:
            pushNext()
        case .authorizedWhenInUse:
            pushNext()
        }
        
        authorizationStatusChecked = true
    }
}

extension OnBoardingShareController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        doNext()
    }
}
