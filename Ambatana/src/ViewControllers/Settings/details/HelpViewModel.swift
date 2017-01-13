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
    case terms
    case privacy
}

protocol HelpViewModelDelegate: BaseViewModelDelegate {
}

class HelpViewModel: BaseViewModel {
   
    let myUserRepository: MyUserRepository
    let installationRepository: InstallationRepository
    weak var navigator: HelpNavigator?
    weak var delegate: HelpViewModelDelegate?
    
    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository, installationRepository: Core.installationRepository)
    }
    
    init(myUserRepository: MyUserRepository, installationRepository: InstallationRepository) {
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
    }
    
    override func backButtonPressed() -> Bool {
        if let navigator = navigator {
            navigator.closeHelp()
        } else {
            return false // Return false for native behavior
        }
        return true
    }
    
    var url: URL? {
        return LetgoURLHelper.buildHelpURL(myUserRepository.myUser, installation: installationRepository.installation)
    }

    var termsAndConditionsURL: URL? {
        return LetgoURLHelper.buildTermsAndConditionsURL()
    }
    
    var privacyURL: URL? {
        return LetgoURLHelper.buildPrivacyURL()
    }
    
    func termsButtonPressed() {
        guard let url = termsAndConditionsURL else { return }
        if let navigator = navigator {
            navigator.openURL(url)
        } else {
            delegate?.vmOpenInternalURL(url)
        }
    }
    
    func privacyButtonPressed() {
        guard let url = privacyURL else { return }
        if let navigator = navigator {
            navigator.openURL(url)
        } else {
            delegate?.vmOpenInternalURL(url)
        }
    }
}
