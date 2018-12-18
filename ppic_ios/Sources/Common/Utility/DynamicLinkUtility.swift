//
//  DynamicLinkUtility.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/18.

//

import Foundation
import FirebaseDynamicLinks

class DynamicLinkUtility {
    enum Links: String {
        case pics = "/pics"
    }
    
    static func makePickDetailLink(id: String, completion: @escaping (URL?) -> Void) {
        let url = "https://\(EnvUtility.dynamicLinkDomain)\(Links.pics.rawValue)?id=\(id)"
        
        return self.makeDynamicLink(with: url, completion: completion)
    }
    
    private static func makeDynamicLink(with link: String, completion: @escaping (URL?) -> Void) {
        guard let linkURL = URL(string: link) else {
            return completion(nil)
        }
        
        let components = DynamicLinkComponents(link: linkURL, domain: EnvUtility.dynamicLinkDomain)
        
        // TODO: https://firebase.google.com/docs/dynamic-links/create-manually?hl=ja 記載の "efr" は以下と思われる。必要か不要か要確認
//        let navigationInfoParameters = DynamicLinkNavigationInfoParameters()
//        navigationInfoParameters.isForcedRedirectEnabled = true
//        components.navigationInfoParameters = navigationInfoParameters

        let componentsOptions = DynamicLinkComponentsOptions()
        componentsOptions.pathLength = .unguessable
        components.options = componentsOptions
        
        let bundleID = Bundle.main.bundleIdentifier!
        let iosParameters = DynamicLinkIOSParameters(bundleID: bundleID)
        iosParameters.appStoreID = EnvUtility.appStoreId
        components.iOSParameters = iosParameters
        
        guard let longlink = components.url else {
            return completion(nil)
        }
        
        components.shorten { (url, warnings, error) in
            guard let shortlink = url else {
                print("longlink: \(longlink.absoluteString) original: \(linkURL)")
                return completion(longlink)
            }
            
            print("shortenlink: \(shortlink.absoluteString) original: \(linkURL)")
            return completion(shortlink)
        }
    }
}
