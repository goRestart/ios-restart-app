import Foundation
import LGCoreKit
import LGComponents
import RxSwift

final class PasswordlessEmailViewModel: BaseViewModel {

    var router: LoginNavigator?
    weak var delegate: BaseViewModelDelegate?

    private let sessionManager: SessionManager
    private let tracker: Tracker
    private let installationRepository: InstallationRepository

    init(sessionManager: SessionManager = Core.sessionManager,
         installationRepository: InstallationRepository = Core.installationRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.sessionManager = sessionManager
        self.installationRepository = installationRepository
        self.tracker = tracker
    }

    let isContinueActionEnabled = Variable<Bool>(false)

    func didChange(email: String?) {
        isContinueActionEnabled.value = email?.isEmail() ?? false
    }

    func didTapContinueWith(email: String) {
        sessionManager.requestPasswordlessWith(email: email) { [weak self] result in
            switch result {
            case .success:
                self?.router?.showPasswordlessEmailSent(email: email)
            case .failure(let error):
                switch error {
                case .scammer:
                    self?.showScammerAlert(email, network: .passwordless)
                case .nonExistingEmail:
                    self?.showDeviceNotAllowedAlert(email, network: .passwordless)
                default:
                    self?.showGenericError()
                }

                break
            }
        }
        tracker.trackEvent(.loginEmailSubmit())
    }

    private func showGenericError() {
        let message = R.Strings.commonErrorGenericBody
        delegate?.vmShowAutoFadingMessage(message, completion: nil)
    }

    func didTapHelp() {
        router?.showHelp()
    }

    private func showScammerAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: userEmail,
                                                                installation: installationRepository.installation,
                                                                listing: nil,
                                                                type: .scammer) else {
                                                                    router?.close()
                                                                    return
        }

        let contact = UIAction(
            interface: .button(R.Strings.loginScammerAlertContactButton, .primary(fontSize: .medium)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network))
                self.router?.close(onFinish: { self.router?.open(url: contactURL) })
        })
        let keepBrowsing = UIAction(
            interface: .button(R.Strings.loginScammerAlertKeepBrowsingButton, .secondary(fontSize: .medium,
                                                                                         withBorder: false)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network))
                self.router?.close()
        })

        let actions = [contact, keepBrowsing]

        router?.showAlert(
            withTitle: R.Strings.loginScammerAlertTitle,
            andBody: R.Strings.loginScammerAlertMessage,
            andType: .iconAlert(icon: R.Asset.IconsButtons.icModerationAlert.image),
            andActions: actions
        )

        tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network))
    }

    private func showDeviceNotAllowedAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: userEmail,
                                                                installation: installationRepository.installation,
                                                                listing: nil,
                                                                type: .deviceNotAllowed) else {
                                                                    router?.close()
                                                                    return
        }

        let contact = UIAction(
            interface: .button(R.Strings.loginDeviceNotAllowedAlertContactButton, .primary(fontSize: .medium)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network))
                self.router?.close(onFinish: { self.router?.open(url: contactURL) })
        })

        let keepBrowsing = UIAction(
            interface: .button(R.Strings.loginDeviceNotAllowedAlertOkButton, .secondary(fontSize: .medium,
                                                                                        withBorder: false)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network))
                self.router?.close()
        })

        router?.showAlert(
            withTitle: R.Strings.loginDeviceNotAllowedAlertTitle,
            andBody: R.Strings.loginDeviceNotAllowedAlertMessage,
            andType: .iconAlert(icon: R.Asset.IconsButtons.icDeviceBlockedAlert.image),
            andActions: [contact, keepBrowsing])

        tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network))
    }
}
