//
//  EnvUtility.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/17.

//

import Foundation

class EnvUtility {
    static var googleServiceInfo: String {
        #if STAGING
        return "GoogleService-Info.staging"
        #elseif DEBUG
        return "GoogleService-Info.staging"
        #else
        return "GoogleService-Info"
        #endif
    }
    
    static var apiEndPoint: String {
        #if STAGING
        return "https://ppic-staging2.appspot.com/v1/"
        #elseif DEBUG
        return "https://ppic-staging2.appspot.com/v1/"
        #else
        return "https://ppic-production2.appspot.com/v1/"
        #endif
    }

    static var dynamicLinkDomain: String {
        #if STAGING
        return "ppicstg.page.link"
        #elseif DEBUG
        return "ppicstg.page.link"
        #else
        return "ppic.page.link"
        #endif
    }
    
    static var appStoreId: String {
        return "1412186916"
    }
}

