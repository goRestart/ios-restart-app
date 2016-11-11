//
//  ProfileTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

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
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository, keyValueStorage: keyValueStorage, tracker: tracker,
                  rootViewController: rootViewController)

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
        let vc = ChangeUsernameViewController()
        navigationController.pushViewController(vc, animated: true)
    }

    func openEditLocation() {
        let vc = EditLocationViewController(viewModel: EditLocationViewModel(mode: .EditUserLocation))
        navigationController.pushViewController(vc, animated: true)
    }

    func openCreateCommercials() {
        let vc = CreateCommercialViewController(viewModel: CreateCommercialViewModel())
        navigationController.pushViewController(vc, animated: true)
    }

    func openChangePassword() {
        let vc = ChangePasswordViewController()
        navigationController.pushViewController(vc, animated: true)
    }

    func openHelp() {
        let vc = HelpViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
