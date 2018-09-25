import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsPayoutViewModel: BaseViewModel {
    var navigator: P2PPaymentsOfferStatusWireframe?
    weak var delegate: BaseViewModelDelegate?
    private let offerId: String
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository
    private let tracker: Tracker
    private var offer: P2PPaymentOffer?
    private var priceBreakdown: P2PPaymentPayoutPriceBreakdown?
    private lazy var uiStateRelay = BehaviorRelay<UIState>(value: .loading)
    private let paymentsManager: PaymentsManager = LGPaymentsManager()

    init(offerId: String,
         p2pPaymentsRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository,
         myUserRepository: MyUserRepository = Core.myUserRepository,
         installationRepository: InstallationRepository = Core.installationRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.offerId = offerId
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
        self.tracker = tracker
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            fetchOffer()
        }
    }

    private func fetchOffer() {
        p2pPaymentsRepository.showOffer(id: offerId) { [weak self] result in
            switch result {
            case .success(let offer):
                self?.offer = offer
                self?.fetchPriceBreakdown()
            case .failure:
                self?.uiStateRelay.accept(.errorRetry)
            }
        }
    }

    private func fetchPriceBreakdown() {
        guard let offer = offer else { return }
        let amount = offer.fees.amount
        let currency = offer.fees.currency
        p2pPaymentsRepository.calculatePayoutPriceBreakdown(amount: amount, currency: currency) { [weak self] result in
            switch result {
            case .success(let priceBreakdown):
                self?.priceBreakdown = priceBreakdown
                self?.checkIfUserNeedsToRegister()
            case .failure:
                self?.uiStateRelay.accept(.errorRetry)
            }
        }
    }

    private func checkIfUserNeedsToRegister() {
        guard let userId = myUserRepository.myUser?.objectId else {
            uiStateRelay.accept(.errorRetry)
            return
        }
        p2pPaymentsRepository.showSeller(id: userId) { [weak self] result in
            switch result {
            case .success(let seller):
                if seller.hasAcceptedTOS {
                    self?.showPayoutInfo()
                } else {
                    self?.uiStateRelay.accept(.register)
                }
            case .failure:
                self?.uiStateRelay.accept(.errorRetry)
            }
        }
    }

    private func showPayoutInfo() {
        guard let priceBreakdown = priceBreakdown, let fundsAvailableDate = offer?.fundsAvailableDate else { return }
        let payoutState = UIState.createPayout(priceBreakdown: priceBreakdown,
                                               fundsAvailableDate: fundsAvailableDate)
        uiStateRelay.accept(payoutState)
    }

    private func registerSeller(params: RegistrationParams) {
        guard let userId = myUserRepository.myUser?.objectId else { return }
        guard let countryCode = myUserRepository.myUser?.postalAddress.countryCode else { return }
        delegate?.vmShowLoading(nil)
        let params = P2PPaymentCreateSellerParams(sellerId: userId,
                                                  firstName: params.firstName,
                                                  lastName: params.lastName,
                                                  address: params.address,
                                                  countryCode: countryCode,
                                                  state: params.state,
                                                  city: params.city,
                                                  zipcode: params.zipCode,
                                                  birthDate: params.dateOfBirth,
                                                  ssnLastFour: params.ssnLastFour)
        p2pPaymentsRepository.updateSeller(params: params) { [weak self] result in
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
            switch result {
            case .success:
                self?.trackUserDetailsEntered()
                self?.showPayoutInfo()
            case .failure:
                self?.trackUserDetailsError()
                self?.showGenericError()
            }
        }
    }

    func requestBankAccountPayout(routingNumber: String, accountNumber: String) {
        guard let countryCode = myUserRepository.myUser?.postalAddress.countryCode else { return }
        guard let offer = offer else { return }
        delegate?.vmShowLoading(nil)
        let params = BankAccountParams(routingNumber: routingNumber,
                                       accountNumber: accountNumber,
                                       countryCode: countryCode,
                                       currency: offer.fees.currency)
        paymentsManager.createBankAccountToken(params: params) { [weak self] result in
            switch result {
            case .success(let token):
                self?.trackBankAccountEntered()
                self?.requestPayoutWithToken(token, isInstant: false)
            case .failure:
                self?.trackBankAccountError()
                self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
                self?.showGenericError()
            }
        }
    }

    private func requestCardPayout(name: String,
                                   cardNumber: String,
                                   cardExpirationMonth: Int,
                                   cardExpirationYear: Int,
                                   cvc: String,
                                   isInstant: Bool) {
        guard let offer = offer else { return }
        delegate?.vmShowLoading(nil)
        let params = CardParams(name: name,
                                number: cardNumber,
                                expirationMonth: cardExpirationMonth,
                                expirationYear: cardExpirationYear,
                                cvc: cvc,
                                currency: offer.fees.currency)
        paymentsManager.createCardToken(params: params) { [weak self] result in
            switch result {
            case .success(let token):
                self?.trackDebitCardEntered()
                self?.requestPayoutWithToken(token, isInstant: isInstant)
            case .failure:
                self?.trackDebitCardError()
                self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
                self?.showGenericError()
            }
        }
    }

    private func requestPayoutWithToken(_ token: String, isInstant: Bool) {
        guard let offerId = offer?.objectId else { return }
        let params = P2PPaymentRequestPayoutParams(offerId: offerId,
                                                   stripeToken: token,
                                                   isInstant: isInstant)
        p2pPaymentsRepository.requestPayout(params: params) { [weak self] result in
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
            switch result {
            case .success:
                self?.navigator?.close()
            case .failure:
                self?.showGenericError()
            }
        }
    }

    private func showGenericError() {
        let cancelAction = UIAction(interface: .text(R.Strings.paymentsPayoutPersonalInfoErrorOkButton), action: {})
        delegate?.vmShowAlert(R.Strings.paymentsPayoutPersonalInfoErrorTitle,
                              message: R.Strings.paymentsPayoutPersonalInfoErrorDescription,
                              actions: [cancelAction])
    }

    // MARK: Tracking

    private func trackUserDetailsEntered() {
        guard let offer = offer else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsPayoutUserInfoEntered(offer: offer)
        tracker.trackEvent(trackerEvent)
    }

    private func trackUserDetailsError() {
        guard let offer = offer else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsPayoutUserInfoError(offer: offer)
        tracker.trackEvent(trackerEvent)
    }

    private func trackBankAccountEntered() {
        guard let offer = offer else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsPayoutBankAccountEntered(offer: offer)
        tracker.trackEvent(trackerEvent)
    }

    private func trackBankAccountError() {
        guard let offer = offer else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsPayoutBankAccountError(offer: offer)
        tracker.trackEvent(trackerEvent)
    }

    private func trackDebitCardEntered() {
        guard let offer = offer else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsPayoutDebitCardEntered(offer: offer)
        tracker.trackEvent(trackerEvent)
    }

    private func trackDebitCardError() {
        guard let offer = offer else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsPayoutDebitCardError(offer: offer)
        tracker.trackEvent(trackerEvent)
    }
}

// MARK: - UI Actions

extension P2PPaymentsPayoutViewModel {
    struct RegistrationParams {
        let firstName: String
        let lastName: String
        let dateOfBirth: Date
        let ssnLastFour: String
        let address: String
        let zipCode: String
        let city: String
        let state: String
    }

    struct BankAccountPayoutParams {
        let routingNumber: String
        let accountNumber: String
    }

    struct CardPayoutParams {
        let name: String
        let cardNumber: String
        let cardExpirationMonth: Int
        let cardExpirationYear: Int
        let cvc: String
        let isInstant: Bool
    }

    func registerButtonPressed(params: RegistrationParams) {
        registerSeller(params: params)
    }

    func payoutButtonPressed(params: BankAccountPayoutParams) {
        requestBankAccountPayout(routingNumber: params.routingNumber,
                                 accountNumber: params.accountNumber)
    }

    func payoutButtonPressed(params: CardPayoutParams) {
        requestCardPayout(name: params.name,
                          cardNumber: params.cardNumber,
                          cardExpirationMonth: params.cardExpirationMonth,
                          cardExpirationYear: params.cardExpirationYear,
                          cvc: params.cvc,
                          isInstant: params.isInstant)
    }

    func closeButtonPressed() {
        navigator?.close()
    }

    func retryButtonPressed() {
        fetchOffer()
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

extension P2PPaymentsPayoutViewModel {
    var showLoadingIndicator: Driver<Bool> { return uiStateRelay.asDriver().map { $0.showLoadingIndicator } }
    var registerIsHidden: Driver<Bool> { return uiStateRelay.asDriver().map { $0.registerIsHidden } }
    var payoutIsHidden: Driver<Bool> { return uiStateRelay.asDriver().map { $0.payoutIsHidden } }
    var errorRetryIsHidden: Driver<Bool> { return uiStateRelay.asDriver().map { $0.errorRetryIsHidden } }
    var feeText: Driver<String?> { return uiStateRelay.asDriver().map { $0.feeText } }
    var standardFundsAvailableText: Driver<String?> { return uiStateRelay.asDriver().map { $0.standardFundsAvailableText } }
    var instantFundsAvailableText: Driver<String?> { return uiStateRelay.asDriver().map { $0.instantFundsAvailableText } }
}
