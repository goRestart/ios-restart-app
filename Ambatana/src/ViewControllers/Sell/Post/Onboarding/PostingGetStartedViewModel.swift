//
//  PostingGetStartedViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

class PostingGetStartedViewModel: BaseViewModel {
    
    weak var navigator: PostingHastenedCreateProductNavigator?

    var myUserRepository: MyUserRepository
    var userAvatarURL: URL? {
        return myUserRepository.myUser?.avatar?.fileURL
    }
    var userName: String? {
        return myUserRepository.myUser?.shortName
    }

    var welcomeText: String {
        guard let name = userName else { return "_Welcome" }
        return "Welcome \(name)"
    }

    var infoText: String {
        return "_ See how easy it is to sell on letgo, post something you got around you"
    }

    var buttonText: String {
        return "_ Get Started"
    }
    
    // MARK: - Lifecycle
    
    override convenience init() {
        self.init(myUserRepository: Core.myUserRepository)
    }

    init(myUserRepository: MyUserRepository) {
        self.myUserRepository = myUserRepository
        super.init()
    }
    
    
    // MARK: - Navigation
    
    func nextAction() {
        navigator?.openCamera()
    }
}

