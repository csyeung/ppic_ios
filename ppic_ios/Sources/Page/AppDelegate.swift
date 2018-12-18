//
//  AppDelegate.swift
//  ppic
//
//  Created by Jonathan YEUNG on 2018/07/04.Í
//

import UIKit
import Firebase
import SVProgressHUD
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var storeURL: String?
    var transitionDelegate: TransitionDelegate?
	let appResolver: AppResolver = ProductionAppResolver()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // firebase
        setFirebase(application)
        
        // svprogrsshud
        SVProgressHUD.setDefaultMaskType(.clear)

        // login
        authenticatedOrOnBoarding {
            self.toMainPage()
        }

        AnalyticsEventUtility.shared.send(name: .boot)

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            guard let url = dynamiclink?.url else {
                return
            }
            
            print("From UniversalLink \(url)")

            if url.relativePath == DynamicLinkUtility.Links.pics.rawValue {
                guard let urlComponents = URLComponents(string: url.absoluteString) else {
                    return
                }
                
                guard let id = urlComponents.queryItems?.first(where: { $0.name == "id" })?.value else {
                    return
                }
                
                AnalyticsEventUtility.shared.send(name: .bootFromDynamicLink, picId: id)

                self.authenticatedOrOnBoarding {
                    self.toPicDetailPage(id: id)
                }
            }
        }
        
        return handled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    private func setFirebase(_ application : UIApplication) {
        FirebaseApp.configure()

        // https://firebase.google.com/docs/cloud-messaging/ios/client?hl=ja
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
    }

    private func authenticatedOrOnBoarding(authenticated: @escaping () -> Void) {
        // version check.
        checkVersion { [weak self] shouldupdate in
            if shouldupdate {
                self?.doUpdate()
            } else {
                // firebaseにログイン済みの匿名ユーザを、端末上から強制的に削除する為のdebug用コード
                //        do {
                //            try Auth.auth().signOut()
                //        } catch let signOutError as NSError {
                //            print ("Error signing out: %@", signOutError)
                //        }

                if let user = Auth.auth().currentUser {
                    print(user.uid)
                    
                    // 起動時には必ずキャッシュをクリアする
                    let userRepository = UserRepository()
                    
                    userRepository.findMineForceRefresh { _ in
                        authenticated()
                    }
                    
                    return
                }
                
                guard let onBoarding = UIStoryboard(name: "OnBoardingWelcome", bundle: nil).instantiateInitialViewController() as? OnBoardingWelcomeController else { return }

                let next = UINavigationController(rootViewController: onBoarding)
                next.isNavigationBarHidden = true
                self?.window?.rootViewController = next
            }
        }
    }

    // メイン画面へ
    func toMainPage() {
        guard let next = UIStoryboard(name: "MainMap", bundle: nil).instantiateInitialViewController() as? MainMapController else { return }
        self.appResolver.inject(toMainMapController: next)
        self.window?.rootViewController = next
    }

    func toPicDetailPage(id: String) {
        guard let next = UIStoryboard(name: "PicDetail", bundle: nil).instantiateInitialViewController() as? PicDetailController else { return }
        next.id = id
        self.window?.rootViewController = next
    }

    private func checkVersion(shouldupdate: @escaping (Bool) -> Void) {
        // current app version.
        guard let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let currentVersion = Double(ver) else {return}
        
        // minimum version.
        let config = RemoteConfig.remoteConfig()
        config.fetch(withExpirationDuration: 0) { (status, error) in
            if let error = error {
                print(error.localizedDescription)
                return shouldupdate(false)
            }

            if status == .success {
                config.activateFetched()
            }
            
            guard let minimumVersion = config.configValue(forKey: "minimum_version").numberValue?.doubleValue else {return}
            self.storeURL = config.configValue(forKey: "apple_store_url").stringValue
            print("current = \(currentVersion), minimum = \(minimumVersion)")
            return shouldupdate(currentVersion < minimumVersion)
        }
    }

    private func doUpdate() {
        let alert = UIAlertController(title: nil, message: "より安定した新しいバージョンが更新されています。アプリを最新版にアップデートしてください。", preferredStyle: .alert)
        let action = UIAlertAction(title: "今すぐアップデート", style: .default) { [weak self] action in
            guard let storeURL = self?.storeURL, let url = URL(string: storeURL) else {return}
            if UIApplication.shared.canOpenURL(url) {
                print("store url = \(url.path)")
                UIApplication.shared.openURL(url)
                exit(0)
            }
        }
        
        alert.addAction(action)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // Change this to your preferred presentation option
        completionHandler([.alert, .sound])
    }
}
