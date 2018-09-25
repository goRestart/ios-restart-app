import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsCreateOfferViewModel: BaseViewModel {
    var navigator: P2PPaymentsMakeAnOfferNavigator?
    weak var delegate: BaseViewModelDelegate?
    private let chatConversation: ChatConversation
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository
    private let tracker: Tracker
    private let paymentsManager: PaymentsManager
    fileprivate let currencyHelper = Core.currencyHelper

    private let listingImageViewURLRelay = BehaviorRelay<URL?>(value: nil)
    private let listingTitleRelay = BehaviorRelay<String?>(value: nil)
    private let uiStateRelay = BehaviorRelay<UIState>(value: .loading)
    private let paymentButtonStateRelay = BehaviorRelay<PaymentButtonState>(value: .hidden)
    private let offerFeesRelay = BehaviorRelay<P2PPaymentOfferFees?>(value: nil)
    private let currencyCodeRelay = BehaviorRelay<String?>(value: nil)
    private let offerAmountRelay = BehaviorRelay<Decimal>(value: 0)
    private let offerAmountStateRelay = BehaviorRelay<OfferAmountState?>(value: nil)
    private let paymentAuthControllerRelay = BehaviorRelay<UIViewController?>(value: nil)

    init(chatConversation: ChatConversation,
         p2pPaymentsRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository,
         myUserRepository: MyUserRepository = Core.myUserRepository,
         installationRepository: InstallationRepository = Core.installationRepository,
         tracker: Tracker = TrackerProxy.sharedInstance,
         paymentsManager: PaymentsManager = LGPaymentsManager()) {
        self.chatConversation = chatConversation
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
        self.tracker = tracker
        self.paymentsManager = paymentsManager
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            setup()
        }
        updatePaymentCapabilities()
    }

    private func setup() {
        configureListing()
        calculateFees()
    }

    private func configureListing() {
        listingImageViewURLRelay.accept(chatConversation.listing?.image?.fileURL)
        listingTitleRelay.accept(chatConversation.listing?.title)
        currencyCodeRelay.accept(chatConversation.listing?.currency.code)
        offerAmountRelay.accept(Decimal(chatConversation.listing?.price.value ?? 0))
    }

    private func calculateFees() {
        guard
            let currency = chatConversation.listing?.currency,
            isOfferAmountValid(offer: offerAmountRelay.value) else {
                delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
                uiStateRelay.accept(.changeOffer)
                return
        }
        let params = P2PPaymentCalculateOfferFeesParams(amount: offerAmountRelay.value, currency: currency)
        p2pPaymentsRepository.calculateOfferFees(params: params) { [weak self] result in
            switch result {
            case .success(let offerFees):
                self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
                self?.updateOfferFees(offerFees)
            case .failure(_):
                self?.delegate?.vmHideLoading(R.Strings.paymentsLoadingGenericError,
                                              afterMessageCompletion: nil)
                self?.uiStateRelay.accept(.changeOffer)
            }
        }
    }

    private func isOfferAmountValid(offer: Decimal) -> Bool {
        return offer >= OfferAmountInterval.min && offer <= OfferAmountInterval.max
    }

    private func updateOfferFees(_ offerFees: P2PPaymentOfferFees) {
        offerFeesRelay.accept(offerFees)
        uiStateRelay.accept(.buy)
    }

    private func updatePaymentCapabilities() {
        switch paymentsManager.canMakePayments() {
        case .unavailable:
            paymentButtonStateRelay.accept(.hidden)
        case .notConfigured:
            paymentButtonStateRelay.accept(.configure)
        case .readyToPay:
            paymentButtonStateRelay.accept(.pay)
        }
    }

    private func startPaymentRequest() {
        guard
            let listingId = chatConversation.listing?.objectId,
            let buyerId = myUserRepository.myUser?.objectId,
            let sellerId = chatConversation.interlocutor?.objectId,
            let currency = chatConversation.listing?.currency,
            let offerFees = offerFeesRelay.value,
            let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String else {
                return
        }
        trackMakeAnOfferApplePayStart()
        let paymentRequest = PaymentRequest(listingId: listingId,
                                            buyerId: buyerId,
                                            sellerId: sellerId,
                                            sellerAmount: offerFees.amount as NSDecimalNumber,
                                            feeAmount: offerFees.serviceFee as NSDecimalNumber,
                                            totalAmount: offerFees.total as NSDecimalNumber,
                                            currency: currency,
                                            countryCode: countryCode)
        let authController = paymentsManager.createPaymentRequestController(paymentRequest) { [weak self] result in
            self?.paymentAuthControllerRelay.accept(nil)
            switch result {
            case .success:
                self?.trackMakeAnOfferComplete()
                delay(P2PPayments.chatRefreshDelay) { [weak self] in
                    self?.navigator?.closeOnboarding()
                }
            case .failure: break
            }
        }
        paymentAuthControllerRelay.accept(authController)
    }

    private func trackMakeAnOfferAbandon() {
        guard let userId = myUserRepository.myUser?.objectId,
        let offerFees = offerFeesRelay.value else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsMakeAnOfferAbandon(userId: userId,
                                                                      chatConversation: chatConversation,
                                                                      offerFees: offerFees)
        tracker.trackEvent(trackerEvent)
    }

    private func trackMakeAnOfferApplePayStart() {
        guard let userId = myUserRepository.myUser?.objectId,
            let offerFees = offerFeesRelay.value else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsMakeAnOfferPaymentStart(userId: userId,
                                                                           chatConversation: chatConversation,
                                                                           offerFees: offerFees)
        tracker.trackEvent(trackerEvent)
    }

    private func trackMakeAnOfferComplete() {
        guard let userId = myUserRepository.myUser?.objectId,
            let offerFees = offerFeesRelay.value else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsMakeAnOfferPaymentComplete(userId: userId,
                                                                              chatConversation: chatConversation,
                                                                              offerFees: offerFees)
        tracker.trackEvent(trackerEvent)
    }

    private func trackMakeAnOfferEditPriceStart() {
        guard let userId = myUserRepository.myUser?.objectId else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsMakeAnOfferEditPriceStart(userId: userId,
                                                                             chatConversation: chatConversation)
        tracker.trackEvent(trackerEvent)
    }

    private func trackMakeAnOfferEditPriceCancel() {
        guard let userId = myUserRepository.myUser?.objectId else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsMakeAnOfferEditPriceCancel(userId: userId,
                                                                              chatConversation: chatConversation)
        tracker.trackEvent(trackerEvent)
    }

    private func trackMakeAnOfferEditPriceComplete() {
        guard let userId = myUserRepository.myUser?.objectId else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsMakeAnOfferEditPriceComplete(userId: userId,
                                                                                chatConversation: chatConversation)
        tracker.trackEvent(trackerEvent)
    }
}

// MARK: - Inner types

extension P2PPaymentsCreateOfferViewModel {
    enum UIState {
        case loading, buy, changeOffer
    }

    enum PaymentButtonState {
        case hidden, configure, pay
    }

    enum OfferAmountState {
        case valid, invalid
    }

    struct OfferAmountInterval {
        static let min: Decimal = 5
        static let max: Decimal = 500
    }
}

// MARK: - UI Actions

extension P2PPaymentsCreateOfferViewModel {
    func closeButtonPressed() {
        if uiStateRelay.value == .changeOffer, isOfferAmountValid(offer: offerAmountRelay.value) {
            trackMakeAnOfferEditPriceCancel()
            uiStateRelay.accept(.buy)
        } else {
            trackMakeAnOfferAbandon()
            navigator?.closeOnboarding()
        }
    }

    func changeOfferButtonPressed() {
        trackMakeAnOfferEditPriceStart()
        uiStateRelay.accept(.changeOffer)
    }

    func changeOfferDoneButtonPressed(newValue: Decimal) {
        guard isOfferAmountValid(offer: newValue) else {
            offerAmountStateRelay.accept(.invalid)
            return
        }
        trackMakeAnOfferEditPriceComplete()
        offerAmountRelay.accept(newValue)
        delegate?.vmShowLoading(nil)
        calculateFees()
    }

    func configurePaymentButtonPressed() {
        paymentsManager.openPaymentSetup()
    }

    func payButtonPressed() {
        startPaymentRequest()
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

extension P2PPaymentsCreateOfferViewModel {
    private static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    var listingImageViewURL: Driver<URL?> { return listingImageViewURLRelay.asDriver() }
    var listingTitle: Driver<String?> { return listingTitleRelay.asDriver() }
    var uiState: Driver<UIState> { return uiStateRelay.asDriver() }
    var paymentButtonState: Driver<PaymentButtonState> { return paymentButtonStateRelay.asDriver() }
    var currencyCode: Driver<String?> { return currencyCodeRelay.asDriver() }
    var offerAmount: Driver<Decimal> { return offerAmountRelay.asDriver() }
    var offerAmountState: Driver<OfferAmountState?> { return offerAmountStateRelay.asDriver() }
    var paymentAuthController: Driver<UIViewController?> { return paymentAuthControllerRelay.asDriver() }

    var configurePaymentButtonHidden: Driver<Bool> {
        return Driver.combineLatest(uiState, paymentButtonState) { (uiState, buttonState) -> Bool in
            switch (uiState, buttonState) {
            case (.buy, .configure): return false
            default: return true
            }
        }
    }

    var buyButtonHidden: Driver<Bool> {
        return Driver.combineLatest(uiState, paymentButtonState) { (uiState, buttonState) -> Bool in
            switch (uiState, buttonState) {
            case (.buy, .pay): return false
            default: return true
            }
        }
    }

    var priceAmountText: Driver<String?> {
        return offerFeesRelay.asDriver().map { [currencyHelper] offerFees in
            guard let fees = offerFees else { return nil }
            let amount = (fees.amount as NSDecimalNumber).doubleValue
            let currency = fees.currency
            return currencyHelper.formattedAmountWithCurrencyCode(currency.code, amount: amount)
        }
    }

    var feeAmountText: Driver<String?> {
        return offerFeesRelay.asDriver().map { [currencyHelper] offerFees in
            guard let fees = offerFees else { return nil }
            let amount = (fees.serviceFee as NSDecimalNumber).doubleValue
            let currency = fees.currency
            return currencyHelper.formattedAmountWithCurrencyCode(currency.code, amount: amount)
        }
    }

    var totalAmountText: Driver<String?> {
        return offerFeesRelay.asDriver().map { [currencyHelper] offerFees in
            guard let fees = offerFees else { return nil }
            let amount = (fees.total as NSDecimalNumber).doubleValue
            let currency = fees.currency
            return currencyHelper.formattedAmountWithCurrencyCode(currency.code, amount: amount)
        }
    }

    var feePercentageText: Driver<String?> {
        return offerFeesRelay.asDriver().map { offerFees in
            guard let fees = offerFees else { return nil }
            let percentage = fees.serviceFeePercentage / 100
            return P2PPaymentsCreateOfferViewModel.percentageFormatter.string(from: NSNumber(value: percentage))
        }
    }

    var invalidAmountMessage: String {
        guard let currencyCode = chatConversation.listing?.currency.code else { return "" }
        let minAmount = currencyHelper.formattedAmountWithCurrencyCode(currencyCode, amount: (OfferAmountInterval.min as NSDecimalNumber).doubleValue)
        let maxAmount = currencyHelper.formattedAmountWithCurrencyCode(currencyCode, amount: (OfferAmountInterval.max as NSDecimalNumber).doubleValue)
        return R.Strings.paymentsChangeOfferInvalidAmountAlertMessage(minAmount, maxAmount)
    }
}
