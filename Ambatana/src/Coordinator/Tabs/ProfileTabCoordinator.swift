//
//  ProfileTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SafariServices

protocol ProfileCoordinatorSearchAlertsDelegate: class {
    func profileCoordinatorSearchAlertsOpenSearch()
}

final class ProfileTabCoordinator: TabCoordinator {

    weak var profileCoordinatorSearchAlertsDelegate: ProfileCoordinatorSearchAlertsDelegate?

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
        let viewModel = UserProfileViewModel.makePrivateProfile(source: .tabBar)
        let rootViewController = UserProfileViewController(viewModel: viewModel)

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
                                               pageType: pageType,
                                               listingCanBeBoosted: false,
                                               timeSinceLastBump: nil,
                                               maxCountdown: 0)
        openChild(coordinator: navigator, parent: rootViewController, animated: true, forceCloseChild: true, completion: nil)
    }

    func openVerificationView() {
        let vm = UserVerificationViewModel()
        vm.navigator = self
        let vc = UserVerificationViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension ProfileTabCoordinator: UserVerificationNavigator {
    func closeUserVerification() {
        navigationController.popViewController(animated: true)
    }

    func openEmailVerification() {
        let vm = UserVerificationEmailViewModel()
        vm.navigator = self
        let vc = UserVerificationEmailViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openPhoneNumberVerification() {
        let vm = UserPhoneVerificationNumberInputViewModel()
        vm.navigator = self
        let vc = UserPhoneVerificationNumberInputViewController(viewModel: vm)
        vm.delegate = vc
        navigationController.pushViewController(vc, animated: true)
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

    func openSettingsNotifications() {
        let vm = SettingsNotificationsViewModel()
        vm.navigator = self
        let vc = SettingsNotificationsViewController(viewModel: vm)
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
        navigationController.openInAppWebViewWith(url: url)
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

extension ProfileTabCoordinator: VerifyUserEmailNavigator {
    func closeEmailVerification() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: UserPhoneVerificationNavigator {
    func openCountrySelector(withDelegate delegate: UserPhoneVerificationCountryPickerDelegate) {
        let vm = UserPhoneVerificationCountryPickerViewModel()
        vm.navigator = self
        vm.delegate = delegate
        let vc = UserPhoneVerificationCountryPickerViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func closeCountrySelector() {
        navigationController.popViewController(animated: true)
    }

    func openCodeInput(sentTo phoneNumber: String, with callingCode: String) {
        let vm = UserPhoneVerificationCodeInputViewModel(callingCode: callingCode,
                                                         phoneNumber: phoneNumber)
        vm.navigator = self
        let vc = UserPhoneVerificationCodeInputViewController(viewModel: vm)
        vm.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }

    func closePhoneVerificaction() {
        guard let vc = navigationController.viewControllers
            .filter({ $0 is UserVerificationViewController }).first else { return }
        navigationController.popToViewController(vc, animated: true)
    }
}

extension ProfileTabCoordinator: SettingsNotificationsNavigator {
    func closeSettingsNotifications() {
        navigationController.popViewController(animated: true)
    }

    func openSearchAlertsList() {
        let vm = SearchAlertsListViewModel()
        vm.navigator = self
        let vc = SearchAlertsListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension ProfileTabCoordinator: SearchAlertsListNavigator {
    func closeSearchAlertsList() {
        navigationController.popViewController(animated: true)
    }

    func openSearch() {
        navigationController.popToRootViewController(animated: false)
        profileCoordinatorSearchAlertsDelegate?.profileCoordinatorSearchAlertsOpenSearch()
    }
}
