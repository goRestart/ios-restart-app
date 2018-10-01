import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsEnterPayCodeViewModel: BaseViewModel {
    var navigator: P2PPaymentsOfferStatusWireframe?
    private let offerId: String
    private var offer: P2PPaymentOffer?
    private let buyerName: String
    private let buyerAvatar: File?
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository
    private let tracker: Tracker
    fileprivate lazy var uiStateRelay = BehaviorRelay<UIState>(value: .enterCode(buyerName: buyerName, buyerAvatar: buyerAvatar))
    private var codeRetries = 0

    init(offerId: String,
         buyerName: String,
         buyerAvatar: File?,
         p2pPaymentsRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository,
         myUserRepository: MyUserRepository = Core.myUserRepository,
         installationRepository: InstallationRepository = Core.installationRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.offerId = offerId
        self.buyerName = buyerName
        self.buyerAvatar = buyerAvatar
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
        self.tracker = tracker
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            fetchOfferInfo()
        }
    }

    private func fetchOfferInfo() {
        p2pPaymentsRepository.showOffer(id: offerId) { [weak self] result in
            switch result {
            case .success(let offer):
                self?.offer = offer
            case .failure:
                break // Fail silently
            }
        }
    }

    private func usePayCode(_ payCode: String) {
        uiStateRelay.accept(.loading(buyerName: buyerName, buyerAvatar: buyerAvatar))
        p2pPaymentsRepository.usePayCode(payCode: payCode, offerId: offerId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                strongSelf.trackCodeCorrect(retries: strongSelf.codeRetries)
                delay(P2PPayments.chatRefreshDelay) { [weak self] in
                    self?.navigator?.close()
                }
            case .failure:
                strongSelf.trackCodeIncorrect(retries: strongSelf.codeRetries)
                strongSelf.codeRetries = strongSelf.codeRetries + 1
                strongSelf.enterPayCode()
            }
        }
    }

    private func enterPayCode() {
        uiStateRelay.accept(.enterCode(buyerName: buyerName, buyerAvatar: buyerAvatar))
    }

    private func trackCodeEntered(retries: Int) {
        guard let offer = offer else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsOfferSellerCodeEntered(offer: offer, retries: retries)
        tracker.trackEvent(trackerEvent)
    }

    private func trackCodeCorrect(retries: Int) {
        guard let offer = offer else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsOfferSellerCodeCorrect(offer: offer, retries: retries)
        tracker.trackEvent(trackerEvent)
    }

    private func trackCodeIncorrect(retries: Int) {
        guard let offer = offer else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsOfferSellerCodeIncorrect(offer: offer, retries: retries)
        tracker.trackEvent(trackerEvent)
    }
}

// MARK: - UI State

extension P2PPaymentsEnterPayCodeViewModel {
    enum UIState {
        case loading(buyerName: String, buyerAvatar: File?)
        case enterCode(buyerName: String, buyerAvatar: File?)

        var showLoadingIndicator: Bool {
            switch self {
            case .loading: return true
            case .enterCode: return false
            }
        }

        var hideCodeTextField: Bool {
            switch self {
            case .loading: return true
            case .enterCode: return false
            }
        }

        var buyerName: String {
            switch self {
            case .loading(buyerName: let name, buyerAvatar: _), .enterCode(buyerName: let name, buyerAvatar: _):
                return name
            }
        }

        var buyerAvatar: File? {
            switch self {
            case .loading(buyerName: _, buyerAvatar: let buyerAvatar):
                return buyerAvatar
            case .enterCode(buyerName: _, buyerAvatar: let buyerAvatar):
                return buyerAvatar
            }
        }

        var descriptionText: String {
            return R.Strings.paymentsEnterPayCodeDescriptionLabel(buyerName)
        }
    }
}

// MARK: - UI Actions

extension P2PPaymentsEnterPayCodeViewModel {
    func payCodeEntered(_ payCode: String) {
        trackCodeEntered(retries: codeRetries)
        usePayCode(payCode)
    }

    func closeButtonPressed() {
        navigator?.close()
    }

    func contactUsActionSelected() {
        guard let email = myUserRepository.myUser?.email,
            let installation = installationRepository.installation,
            let url = LetgoURLHelper.buildContactUsURL(userEmail: email, installation: installation,
                                                       listing: nil, type: .payment) else { return }
        navigator?.openContactUs(url: url)
    }

    func faqsActionSelected() {
        guard let url = LetgoURLHelper.buildPaymentFaqsURL() else { return }
        navigator?.openFaqs(url: url)
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsEnterPayCodeViewModel {
    var showLoadingIndicator: Driver<Bool> { return uiStateRelay.asDriver().map { $0.showLoadingIndicator } }
    var hideCodeTextField: Driver<Bool> { return uiStateRelay.asDriver().map { $0.hideCodeTextField } }
    var buyerImageURL: Driver<URL?> { return uiStateRelay.asDriver().map { $0.buyerAvatar?.fileURL } }
    var descriptionText: Driver<String> { return uiStateRelay.asDriver().map { $0.descriptionText } }
}
