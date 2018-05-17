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

    private let actionsHistory = Variable<[UserReputationActionType]?>(nil)
    private var user: Driver<MyUser?> { return myUserRepository.rx_myUser.asDriver(onErrorJustReturn: nil) }
    var userAvatar: Driver<URL?> { return user.map { $0?.avatar?.fileURL } }
    var userAvatarPlaceholder: Driver<UIImage?> { return user.map { LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor, name: $0?.name) } }
    var userScore: Driver<Int> { return user.map { $0?.reputationPoints ?? 0 } }

    var items: Driver<[[UserVerificationItem]]> {
        return actionsHistory.asDriver().map(buildItems)
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

    func loadData(completion: (() -> Void)? = nil) {
        syncActions()
    }

    // The reputation actions take a few second to be processed.
    // We refresh the actions a few times to make sure the points and actions are up to date.
    private func syncActions(retries: Int = 0) {
        guard retries < 3 else { return }
        refresh { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self?.syncActions(retries: retries + 1)
            })
        }
    }

    private func refresh(success: (() -> Void)? = nil) {
        myUserRepository.retrieveUserReputationActions { [weak self] result in
            if let value = result.value {
                self?.actionsHistory.value = value.map{ $0.type }
                success?()
            } else if let _ = result.error {
                self?.showErrorAlert()
            }
        }
        myUserRepository.refresh(nil)
    }

    private func showErrorAlert() {
        delegate?.vmShowAlertWithTitle(LGLocalizedString.commonErrorTitle,
                                       text: LGLocalizedString.commonErrorNetworkBody,
                                       alertType: .plainAlert,
                                       buttonsLayout: .horizontal,
                                       actions: [UIAction.init(interface: .text(LGLocalizedString.commonOk), action: { [weak self] in
                                        self?.navigator?.closeUserVerification()
                                       })], dismissAction: { [weak self] in
                                        self?.navigator?.closeUserVerification()
        })
    }

    private func buildItems(with actions: [UserReputationActionType]?) -> [[UserVerificationItem]] {
        guard let actions = actions else { return [] }
        let firstSection: [UserVerificationItem] = [
            .facebook(completed: actions.contains(.facebook)),
            .google(completed: actions.contains(.google)),
            .email(completed: actions.contains(.email))
        ]
        
        let secondSection: [UserVerificationItem] = [
            .profilePicture(completed: actions.contains(.avatarUpdated)),
            .bio(completed: actions.contains(.bio))
        ]

        let soldCount = actions.filter{$0 == .markAsSold}.count
        let thirdSection: [UserVerificationItem] = [
            .markAsSold(completed: soldCount >= 5, total: soldCount)
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
                                            self?.syncActions()
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
                        self?.syncActions()
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
                        self?.syncActions()
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
                case .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified, .serverError, .wsChatError,
                     .searchAlertError:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody, completion: nil)
                }
            } else {
                self?.syncActions()
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
