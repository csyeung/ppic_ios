//
//  AnalyticsUtility.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/20.

//

import Foundation
import Firebase

final class AnalyticsEventUtility {
    static let shared = AnalyticsEventUtility()

    private init() {}

    enum EventName: String {
        case boot = "boot"
        case bootFromDynamicLink = "boot_from_dynamic_link"

        case openOnBoardingWelcome = "open_on_boarding_welcome"
        case openOnBoardingShare = "open_on_boarding_share"
        case openOnBoardingRegister = "open_on_boarding_register"
        case openOnBoardingComplete = "open_on_boarding_complete"
        case openPicPost = "open_pic_post"
        case openPicDetail = "open__pic_detail"
        case openChatList = "open_chat_list"
        case openChatMessage = "open_chat_message"
        case openProfile = "open_profile"
        
        case completeLoadMap = "complete_load_map"
        case completeOnBoarding = "complete_on_boarding"
        case completePicPost = "complete_pic_post"
        case completePicClose = "complete_pic_close"
        case completeSendMessage = "complete_send_message"

        case tapMyPicShow = "tap_my_pic_show"
        case tapMyPicShare = "tap_my_pic_share"
        case tapJoinPic = "tap_join_pic"
    }

    func send(name: EventName, picId: String? = nil, picOwnerUid: String? = nil, optionalParameters: [String: Any] = [:]) {
        var parameters: [String: Any] = [:]

        parameters.merge(optionalParameters) { a, b -> Any in
            return a
        }

        if let uid = Firebase.Auth.auth().currentUser?.uid {
            parameters["uid"] = uid
        }
        
        if let picId = picId {
            parameters["pic_id"] = picId
        }
        
        if let picOwnerUid = picOwnerUid {
            parameters["pic_owner_uid"] = picOwnerUid
        }
        
        Firebase.Analytics.logEvent("ppic_\(name.rawValue)", parameters: parameters)
    }
}
