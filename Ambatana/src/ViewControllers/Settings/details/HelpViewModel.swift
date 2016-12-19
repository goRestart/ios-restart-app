//
//  HelpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//


import LGCoreKit
import DeviceUtil

enum HelpURLType {
    case Terms
    case Privacy
}

public class HelpViewModel: BaseViewModel {
   
    let myUserRepository: MyUserRepository
    let installationRepository: InstallationRepository
    weak var navigator: HelpNavigator?
    
    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository, installationRepository: Core.installationRepository)
    }
    
    init(myUserRepository: MyUserRepository, installationRepository: InstallationRepository) {
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
    }
    
    override func backButtonPressed() -> Bool {
        navigator?.closeHelp()
        return true
    }
    
    public var url: NSURL? {
        return LetgoURLHelper.buildHelpURL(myUserRepository.myUser, installation: installationRepository.installation)
    }

    var termsAndConditionsURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.termsAndConditionsURL)
    }
    
    var privacyURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.privacyURL)
    }
    
    func urlFromURLType(type: HelpURLType) -> NSURL?{
        switch type {
        case .Privacy:
           return privacyURL
        case .Terms:
            return termsAndConditionsURL
        }
    }
    
    func openInternalUrl(type: HelpURLType) {
        switch type {
        case .Privacy:
            guard let url = privacyURL else { return }
            navigator?.openURL(url)
        case .Terms:
            guard let url = termsAndConditionsURL else { return }
            navigator?.openURL(url)
        }
    }
}
