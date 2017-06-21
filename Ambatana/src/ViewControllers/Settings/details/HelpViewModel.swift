//
//  HelpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum HelpURLType {
    case terms
    case privacy
}

class HelpViewModel: BaseViewModel {
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let installationRepository: InstallationRepository

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
        navigator?.open(url: url)
    }
    
    func privacyButtonPressed() {
        guard let url = privacyURL else { return }
        navigator?.open(url: url)
    }
}
