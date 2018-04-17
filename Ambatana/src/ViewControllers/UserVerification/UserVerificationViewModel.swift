//
//  UserVerificationViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift
import RxCocoa

protocol UserVerificationViewModelDelegate: BaseViewModelDelegate {
    func startAvatarSelection()
}

final class UserVerificationViewModel: BaseViewModel {

    weak var delegate: UserVerificationViewModelDelegate?
    var navigator: UserVerificationNavigator?
    private let myUserRepository: MyUserRepository
    private let fbLoginHelper: FBLoginHelper
    private let googleHelper: GoogleLoginHelper
    fileprivate let tracker: Tracker

    private let actionsHistory = Variable<[UserReputationAction]>([])
    private var user: Driver<MyUser?> { return myUserRepository.rx_myUser.asDriver(onErrorJustReturn: nil) }
    var userAvatar: Driver<URL?> { return user.map{$0?.avatar?.fileURL} }
    var userScore: Driver<Int> { return .just(42) }

    var items: Driver<[[UserVerificationItem]]> {
        return Driver
            .combineLatest(myUserRepository.rx_myUser.asDriver(onErrorJustReturn: nil), actionsHistory.asDriver())
            .map{($0, $1)}
            .map(buildItems)
    }

    init(myUserRepository: MyUserRepository,
         fbLoginHelper: FBLoginHelper,
         googleHelper: GoogleLoginHelper,
         tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.fbLoginHelper = fbLoginHelper
        self.googleHelper = googleHelper
        self.tracker = tracker
        super.init()
    }

    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository,
                  fbLoginHelper: FBLoginHelper(),
                  googleHelper: GoogleLoginHelper(),
                  tracker: TrackerProxy.sharedInstance)
    }

    private func syncHistory() {
        myUserRepository.retrieveUserReputationActions { [weak self] result in
            if let value = result.value {
                self?.actionsHistory.value = value
            } else if let error = result.error {
                // Show error?
            }
        }
    }

    private func buildItems(with myUser: MyUser?, actions: [UserReputationAction]) -> [[UserVerificationItem]] {
        guard let user = myUser else { return [] }

        let facebookVerified = actions.contains(where: {$0.type == .facebook })
        let googleVerified = actions.contains(where: {$0.type == .google })
        let emailVerified = actions.contains(where: {$0.type == .email })

        let firstSection: [UserVerificationItem] = [
            .facebook(completed: facebookVerified),
            .google(completed: googleVerified),
            .email(completed: emailVerified)
        ]

        let hasProfilePicture = user.avatar?.fileURL != nil || actions.contains(where: {$0.type == .avatarUploaded })
        let hasBio = user.biography != nil
        
        let secondSection: [UserVerificationItem] = [
            .profilePicture(completed: hasProfilePicture),
            .bio(completed: user.biography != nil)
        ]

        let thirdSection: [UserVerificationItem] = [
            .markAsSold(completed: actions.contains(where: {$0.type == .markAsSold }))
        ]

        return [firstSection, secondSection, thirdSection]
    }

    // MARK: - Puclic methods

    func didSelect(item: UserVerificationItem) {
        switch item {
        case .facebook: verifyFacebook()
        case .google: verifyGoogle()
        case .bio: openBio()
        case .email: verifyEmail()
        case .profilePicture: selectAvatar()
        case .phoneNumber, .photoID, .markAsSold: break
        }
    }

    func updateAvatar(with image: UIImage) {
        guard let imageData = image.dataForAvatar() else { return }
        myUserRepository.updateAvatar(imageData,
                                      progressBlock: nil,
                                      completion: { [weak self] result in
                                        if let _ = result.value {
                                            self?.trackUpdateAvatarComplete()
                                        } else {
                                            self?.delegate?
                                                .vmShowAutoFadingMessage(LGLocalizedString.settingsChangeProfilePictureErrorGeneric,
                                                                         completion: nil)
                                        }
        })
    }

    // MARK: - Private methods

    private func verifyFacebook() {
        fbLoginHelper.connectWithFacebook { [weak self] result in
            switch result {
            case let .success(token):
                self?.myUserRepository.linkAccountFacebook(token) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.facebook)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric,
                                                                completion: nil)
                    }
                }
            case .cancelled:
                break
            case .error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric,
                                                        completion: nil)
            }
        }
    }

    private func verifyGoogle() {
        googleHelper.googleSignIn { [weak self] result in
            switch result {
            case let .success(serverAuthToken):
                self?.myUserRepository.linkAccountGoogle(serverAuthToken) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.google)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric,
                                                                completion: nil)
                    }
                }
            case .cancelled:
                break
            case .error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric,
                                                        completion: nil)
            }
        }
    }

    private func verifyEmail() {
        if let email = myUserRepository.myUser?.email, email.isEmail() {
            verifyExistingEmail(email: email)
        } else {
            navigator?.openEmailVerification()
        }
    }

    private func verifyExistingEmail(email: String) {
        guard email.isEmail() else { return }
        myUserRepository.linkAccount(email) { [weak self] result in
            if let error = result.error {
                switch error {
                case .tooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailTooManyRequests,
                                                            completion: nil)
                case .network:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorNetworkBody, completion: nil)
                case .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified, .serverError, .wsChatError:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody, completion: nil)
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess) {
                    self?.verificationSuccess(.email(email))
                }
            }
        }
    }

    private func selectAvatar() {
        delegate?.startAvatarSelection()
    }

    private func openBio() {
        navigator?.openEditUserBio()
    }

    private func verificationSuccess(_ verificationType: VerificationType) {
        trackComplete(verificationType)
    }
}

// MARK: - Trackings

fileprivate extension UserVerificationViewModel {
    func trackStart() {
        let event = TrackerEvent.verifyAccountStart(.profile)
        tracker.trackEvent(event)
    }

    func trackComplete(_ verificationType: VerificationType) {
        let event = TrackerEvent.verifyAccountComplete(.profile, network: verificationType.accountNetwork)
        tracker.trackEvent(event)
    }

    func trackUpdateAvatarComplete() {
        let trackerEvent = TrackerEvent.profileEditEditPicture()
        tracker.trackEvent(trackerEvent)
    }
}

fileprivate extension VerifyAccountsSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .chat:
            return .chat
        case .profile:
            return .profile
        }
    }

    var loginSource: EventParameterLoginSourceValue {
        switch self {
        case .chat:
            return .chats
        case .profile:
            return .profile
        }
    }

    var title: String {
        switch self {
        case let .chat(title, _):
            return title
        case let .profile(title, _):
            return title
        }
    }

    var description: String {
        switch self {
        case let .chat(_, description):
            return description
        case let .profile(_, description):
            return description
        }
    }
}

fileprivate extension VerificationType {
    var accountNetwork: EventParameterAccountNetwork {
        switch self {
        case .facebook:
            return .facebook
        case .google:
            return .google
        case .email:
            return .email
        }
    }
}
