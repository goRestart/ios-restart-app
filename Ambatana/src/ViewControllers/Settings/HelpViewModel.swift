//
//  HelpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//


import LGCoreKit
import DeviceUtil

public class HelpViewModel: BaseViewModel {
   
    let myUserRepository: MyUserRepository
    
    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository)
    }
    
    init(myUserRepository: MyUserRepository) {
        self.myUserRepository = myUserRepository
    }
    
    public var url: NSURL? {
        return LetgoURLHelper.composeURL(Constants.helpURL)
    }

    var termsAndConditionsURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.termsAndConditionsURL)
    }
    
    var privacyURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.privacyURL)
    }
    
    var contactUsURL: NSURL? {
        guard let  url = LetgoURLHelper.composeURL(Constants.contactUs) else { return nil }
        guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = buildContactParameters()
        return urlComponents.URL
    }

    private func buildContactParameters() -> String? {
        var param: [String: String] = [:]
        param["app_version"] = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        param["os_version"] = UIDevice.currentDevice().systemVersion
        param["device_model"] = DeviceUtil.hardwareDescription()
        param["user_id"] = myUserRepository.myUser?.objectId
        param["user_name"] = myUserRepository.myUser?.name
        param["user_email"] = myUserRepository.myUser?.email
        return param.map{"\($0)=\($1)"}
            .joinWithSeparator("&")
            .stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
}
