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
        let sessionManager = Core.sessionManager
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let myUserRepository = Core.myUserRepository
        let installationRepository = Core.installationRepository
        let bubbleNotificationManager =  LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let rootViewController: UIViewController
        let viewModel = UserViewModel.myUserUserViewModel(.tabBar)
        let newViewModel = UserProfileViewModel.makePrivateProfile(source: .tabBar)
        if featureFlags.newUserProfileView.isActive {
            rootViewController = UserProfileViewController(viewModel: newViewModel)
        } else {
            rootViewController = UserViewController(viewModel: viewModel)
        }

        self.init(listingRepository: listingRepository,
                  userRepository: userRepository,
                  chatRepository: chatRepository,
                  myUserRepository: myUserRepository,
                  installationRepository: installationRepository,
                  bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage,
                  tracker: tracker,
                  rootViewController: rootViewController,
                  featureFlags: featureFlags,
                  sessionManager: sessionManager)

        newViewModel.profileNavigator = self
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

    func openEditUserBio() {
        let vm = EditUserBioViewModel()
        vm.navigator = self
        let vc = EditUserBioViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func editListing(_ listing: Listing, pageType: EventParameterTypePage?) {
        let navigator = EditListingCoordinator(listing: listing,
                                               bumpUpProductData: nil,
                                               pageType: pageType)
        openChild(coordinator: navigator, parent: rootViewController, animated: true, forceCloseChild: true, completion: nil)
    }
}

extension ProfileTabCoordinator: SettingsNavigator {
    
    func openEditUserName() {
        let vm = ChangeUsernameViewModel()
        vm.navigator = self
        let vc = ChangeUsernameViewController(vm: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openEditEmail() {
        let vm = ChangeEmailViewModel()
        vm.navigator = self
        let vc = ChangeEmailViewController(with: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openEditLocation(withDistanceRadius distanceRadius: Int?) {
        let vm = EditLocationViewModel(mode: .editUserLocation, distanceRadius: distanceRadius)
        vm.navigator = self
        let vc = EditLocationViewController(viewModel: vm)
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
        navigationController.popViewController(animated: true)
    }
}


extension ProfileTabCoordinator: ChangeUsernameNavigator {
    
    func closeChangeUsername() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: ChangeEmailNavigator {
    
    func closeChangeEmail() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: EditLocationNavigator {
    
    func closeEditLocation() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: ChangePasswordNavigator {
    
    func closeChangePassword() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: HelpNavigator {
    func open(url: URL) {
        let svc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
        svc.view.tintColor = UIColor.primaryColor
        navigationController.present(svc, animated: true, completion: nil)
    }

    func closeHelp() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: EditUserBioNavigator {
    func closeEditUserBio() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: UserPhoneVerificationNavigator {
    func openPhoneInput() {
        let vm = UserPhoneVerificationNumberInputViewModel()
        vm.navigator = self
        let vc = UserPhoneVerificationNumberInputViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openCountrySelector() {
        let vm = UserPhoneVerificationCountryPickerViewModel()
        vm.navigator = self
        let vc = UserPhoneVerificationCountryPickerViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openCodeInput(sentTo phoneNumber: String) {
        let vm = UserPhoneVerificationCodeInputViewModel(phoneNumber: phoneNumber)
        vm.navigator = self
        let vc = UserPhoneVerificationCodeInputViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}
