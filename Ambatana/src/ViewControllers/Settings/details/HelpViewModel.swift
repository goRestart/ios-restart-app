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
    
    public var url: NSURL? {
        return LetgoURLHelper.buildHelpURL(myUserRepository.myUser, installation: installationRepository.installation)
    }

    var termsAndConditionsURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.termsAndConditionsURL)
    }
    
    var privacyURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.privacyURL)
    }
    
    func openInternalUrl(type: HelpURLType) {
        guard let url = privacyURL else { return }
        switch type {
        case .Privacy:
            navigator?.openPrivacy(url)
        case .Terms:
            navigator?.openTerms(url)
        }
    }
}
