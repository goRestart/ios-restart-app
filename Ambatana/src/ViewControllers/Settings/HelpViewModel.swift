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
        return LetgoURLHelper.buildContactUsURL(myUserRepository.myUser)
    }
}
