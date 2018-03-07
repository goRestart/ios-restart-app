//
//  PostingGetStartedViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class PostingGetStartedViewModel: BaseViewModel {
    
    weak var navigator: PostingHastenedCreateProductNavigator?

    var myUserRepository: MyUserRepository
    var userAvatarURL: URL? {
        return myUserRepository.myUser?.avatar?.fileURL
    }
    let userAvatarImage = Variable<UIImage?>(nil)
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

    var buttonIcon: UIImage? {
        return #imageLiteral(resourceName: "ic_camera_blocking_tour")
    }

    var discardText: String {
        return "_ You can discard it later if you don't want to sell it"
    }

    
    // MARK: - Lifecycle
    
    override convenience init() {
        self.init(myUserRepository: Core.myUserRepository)
    }

    init(myUserRepository: MyUserRepository) {
        self.myUserRepository = myUserRepository
        super.init()
        retrieveImageForAvatar()
    }

    func retrieveImageForAvatar() {
        userAvatarImage.value = LetgoAvatar.avatarWithID(myUserRepository.myUser?.objectId, name: userName)

        guard let avatarUrl = userAvatarURL else { return }
        ImageDownloader.sharedInstance.downloadImageWithURL(avatarUrl) { [weak self] result, url in
            guard let imageWithSource = result.value, url == self?.userAvatarURL else { return }
            self?.userAvatarImage.value = imageWithSource.image
        }
    }

    
    // MARK: - Navigation
    
    func nextAction() {
        navigator?.openCamera()
    }
}

