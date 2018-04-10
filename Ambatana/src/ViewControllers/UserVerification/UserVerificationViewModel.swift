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

    private var user: Driver<MyUser?> { return myUserRepository.rx_myUser.asDriver(onErrorJustReturn: nil) }
    var userAvatar: Driver<URL?> { return user.map{$0?.avatar?.fileURL} }
    var userScore: Driver<Int> { return .just(42) }

    var items: Driver<[[UserVerificationItem]]> {
        return myUserRepository.rx_myUser.asDriver(onErrorJustReturn: nil).map { [weak self] in
            self?.buildItems(with: $0) ?? []
        }
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

    private func buildItems(with myUser: MyUser?) -> [[UserVerificationItem]] {
        guard let user = myUser else { return [] }
        let firstSection: [UserVerificationItem] = [
            .facebook(completed: user.facebookAccount?.verified ?? false),
            .google(completed: user.googleAccount?.verified ?? false),
            .email(completed: user.emailAccount?.verified ?? false)
        ]

        let secondSection: [UserVerificationItem] = [
            .profilePicture(completed: user.avatar?.fileURL != nil),
            .bio(completed: user.biography != nil)
        ]

        let thirdSection: [UserVerificationItem] = [
            .markAsSold(completed: false)
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
                                                                completion: { self?.verificationFailed() })
                    }
                }
            case .cancelled:
                break
            case .error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric,
                                                        completion: { self?.verificationFailed() })
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
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: { self?.verificationFailed() })
                    }
                }
            case .cancelled:
                break
            case .error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: { self?.verificationFailed() })
            }
        }
    }

    private func verifyEmail() {

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

    private func verificationFailed() {
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
