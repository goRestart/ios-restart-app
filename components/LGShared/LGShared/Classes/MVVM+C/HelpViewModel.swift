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

public protocol HelpNavigator: class {
    func closeHelp()
}

public class HelpViewModel: BaseViewModel {
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let installationRepository: InstallationRepository

    public weak var navigator: HelpNavigator?
    
    public convenience override init() {
        self.init(myUserRepository: Core.myUserRepository, installationRepository: Core.installationRepository)
    }
    
    init(myUserRepository: MyUserRepository, installationRepository: InstallationRepository) {
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
    }
    
    public override func backButtonPressed() -> Bool {
        navigator?.closeHelp()
        return true
    }
    
    var url: URL? {
        return LetgoURLHelper.buildHelpURL(myUserRepository.myUser, installation: installationRepository.installation)
    }
}
