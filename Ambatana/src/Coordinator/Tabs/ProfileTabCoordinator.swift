//
//  ProfileTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SafariServices

final class ProfileTabCoordinator: TabCoordinator {

    convenience init() {
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let myUserRepository = Core.myUserRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let viewModel = UserViewModel.myUserUserViewModel(.TabBar)
        let rootViewController = UserViewController(viewModel: viewModel)
        let featureFlags = FeatureFlags.sharedInstance
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository, keyValueStorage: keyValueStorage, tracker: tracker,
                  rootViewController: rootViewController, featureFlags: featureFlags)

        viewModel.profileNavigator = self

    }
}

extension ProfileTabCoordinator: ProfileTabNavigator {
    func openSettings() {
        let vm = SettingsViewModel()
        vm.navigator = self
        let vc = SettingsViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension ProfileTabCoordinator: SettingsNavigator {
    func showFbAppInvite() {
        //TODO: INTEGRATE W NEW SHARER
    }

    func openEditUserName() {
        let vm = ChangeUsernameViewModel()
        vm.navigator = self
        let vc = ChangeUsernameViewController(vm: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openEditLocation() {
        let vm = EditLocationViewModel(mode: .EditUserLocation)
        vm.navigator = self
        let vc = EditLocationViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openCreateCommercials() {
        let vc = CreateCommercialViewController(viewModel: CreateCommercialViewModel())
        navigationController.pushViewController(vc, animated: true)
    }

    func openChangePassword() {
        let vm = ChangePasswordViewModel()
        vm.navigator = self
        let vc = ChangePasswordViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openHelp() {
        let vm = HelpViewModel()
        vm.navigator = self
        let vc = HelpViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func closeSettings() {
        navigationController.popViewControllerAnimated(true)
    }
}


extension ProfileTabCoordinator: ChangeUsernameNavigator {
    func userNameSaved() {
        navigationController.popViewControllerAnimated(true)
    }
    
    func closeChangeUsername() {
        navigationController.popViewControllerAnimated(true)
    }
}

extension ProfileTabCoordinator: EditLocationNavigator {
    func locationSaved() {
        navigationController.popViewControllerAnimated(true)
    }
    
    func closeEditLocation() {
        navigationController.popViewControllerAnimated(true)
    }
}

extension ProfileTabCoordinator: ChangePasswordNavigator {
    func passwordSaved() {
        navigationController.popViewControllerAnimated(true)
    }
    
    func closeChangePassword() {
        navigationController.popViewControllerAnimated(true)
    }
}

extension ProfileTabCoordinator: HelpNavigator {
    
    private func openURL(url: NSURL) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
            svc.view.tintColor = UIColor.primaryColor
            self.navigationController.presentViewController(svc, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func openTerms(url: NSURL) {
        openURL(url)
        
    }
    
    func openPrivacy(url: NSURL) {
        openURL(url)
    }
    
    func closeHelp() {
        navigationController.popViewControllerAnimated(true)
    }
}


