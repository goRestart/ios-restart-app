import Foundation
import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents

final class UserVerificationEmailViewModel: BaseViewModel {
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker

    weak var navigator: VerifyUserEmailNavigator?
    weak var delegate: BaseViewModelDelegate?

    init(myUserRepository: MyUserRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
    }

    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance)
    }

    func sendVerification(with email: String) {
        guard email.isEmail() else { return }
        myUserRepository.linkAccount(email) { [weak self] result in
            if let error = result.error {
                switch error {
                case .tooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.profileVerifyEmailTooManyRequests,
                                                            completion: { self?.verificationFailed() })
                case .network:
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorNetworkBody,
                                                            completion: { self?.verificationFailed() })
                case .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified, .serverError, .wsChatError,
                     .searchAlertError:
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorGenericBody,
                                                            completion: { self?.verificationFailed() })
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(R.Strings.profileVerifyEmailSuccess) {
                    self?.verificationSuccess()
                }
            }
        }
    }

    private func verificationSuccess() {
        trackComplete()
        navigator?.closeEmailVerification()
    }

    private func verificationFailed() {
        navigator?.closeEmailVerification()
    }
}

extension UserVerificationEmailViewModel {
    func trackComplete() {
        let event = TrackerEvent.verifyAccountComplete(.profile, network: .email)
        tracker.trackEvent(event)
    }
}
