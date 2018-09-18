import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsPayoutViewModel: BaseViewModel {
    private enum Constants {
        static let secondsInADay: Double = 3600 * 24
        static let minDays: Int = 3
        static let maxDays: Int = 7
    }

    private static let currencyHelper = Core.currencyHelper

    var navigator: P2PPaymentsOfferStatusWireframe?
    private let offerId: String
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let myUserRepository: MyUserRepository
    private var offer: P2PPaymentOffer?
    private var priceBreakdown: P2PPaymentPayoutPriceBreakdown?
    private lazy var uiStateRelay = BehaviorRelay<UIState>(value: .loading)
    private let paymentsManager: PaymentsManager = LGPaymentsManager()

    init(offerId: String,
         p2pPaymentsRepository: P2PPaymentsRepository = Core.p2pPaymentsRepository,
         myUserRepository: MyUserRepository = Core.myUserRepository) {
        self.offerId = offerId
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.myUserRepository = myUserRepository
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
                // TODO: @juolgon hanlde error case
                break
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
                // TODO: @juolgon hanlde error case
                break
            }
        }
    }

    private func checkIfUserNeedsToRegister() {
        guard let userId = myUserRepository.myUser?.objectId else { return }
        p2pPaymentsRepository.showSeller(id: userId) { [weak self] result in
            switch result {
            case .success(let seller):
                if seller.hasAcceptedTOS {
                    self?.showPayoutInfo()
                } else {
                    self?.uiStateRelay.accept(.register)
                }
            case .failure:
                // TODO: @juolgon handle error case
                break
            }
        }
    }

    private func showPayoutInfo() {
        let daysToOffset = calculateFundsAvailableOffsetDays()
        let payoutInfo = PayoutInfo(feeText: getFeeText(),
                                    standardFundsAvailableText: getStandardFundsAvailableText(daysOffset: daysToOffset),
                                    instantFundsAvailableText: getInstantFundsAvailableText(daysOffset: daysToOffset))
        uiStateRelay.accept(.payout(info: payoutInfo))
    }

    private func calculateFundsAvailableOffsetDays() -> Int {
        guard let fundsAvailableDate = offer?.fundsAvailableDate else { return 0 }
        guard fundsAvailableDate.timeIntervalSinceNow > 0 else { return 0 }
        let daysOffset = Int(fundsAvailableDate.timeIntervalSinceNow / Constants.secondsInADay)
        return daysOffset
    }

    private func getFeeText() -> String {
        guard let priceBreakdown = priceBreakdown else { return "" }
        let feeAmountText = P2PPaymentsPayoutViewModel
            .currencyHelper
            .formattedAmountWithCurrencyCode(priceBreakdown.currency.code,
                                             amount: (priceBreakdown.fee as NSDecimalNumber).doubleValue)
        return "(— \(feeAmountText)"
    }

    private func getStandardFundsAvailableText(daysOffset: Int) -> String {
        guard daysOffset > 0 else { return "3-7 days" }
        let minDays = Constants.minDays + daysOffset
        let maxDays = Constants.maxDays + daysOffset
        return "\(minDays)-\(maxDays) days"
    }

    private func getInstantFundsAvailableText(daysOffset: Int) -> String {
        guard daysOffset > 0 else { return "under 1 hour" }
        if daysOffset > 1 {
            return "\(daysOffset) days"
        } else {
            return "1 day"
        }
    }

    private func registerSeller(params: RegistrationParams) {
        guard let userId = myUserRepository.myUser?.objectId else { return }
        guard let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String else { return }
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
            switch result {
            case .success:
                self?.showPayoutInfo()
            case .failure:
                // TODO: @juolgon handle error case
                break
            }
        }
    }

    func requestBankAccountPayout(routingNumber: String, accountNumber: String) {
        guard let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String else { return }
        guard let offer = offer else { return }
        let params = BankAccountParams(routingNumber: routingNumber,
                                       accountNumber: accountNumber,
                                       countryCode: countryCode,
                                       currency: offer.fees.currency)
        paymentsManager.createBankAccountToken(params: params) { [weak self] result in
            switch result {
            case .success(let token):
                self?.requestPayoutWithToken(token)
            case .failure:
                // TODO: @juolgon handle error here
                break
            }
        }
    }

    private func requestCardPayout(name: String,
                                   cardNumber: String,
                                   cardExpirationMonth: Int,
                                   cardExpirationYear: Int,
                                   cvc: String) {
        guard let offer = offer else { return }
        let params = CardParams(name: name,
                                number: cardNumber,
                                expirationMonth: cardExpirationMonth,
                                expirationYear: cardExpirationYear,
                                cvc: cvc,
                                currency: offer.fees.currency)
        paymentsManager.createCardToken(params: params) { [weak self] result in
            switch result {
            case .success(let token):
                self?.requestPayoutWithToken(token)
            case .failure:
                // TODO: @juolgon handle error here
                break
            }
        }
    }

    private func requestPayoutWithToken(_ token: String) {
        guard let offerId = offer?.objectId else { return }
        let params = P2PPaymentRequestPayoutParams(offerId: offerId,
                                                   stripeToken: token,
                                                   isInstant: false)
        p2pPaymentsRepository.requestPayout(params: params) { [weak self] result in
            switch result {
            case .success:
                self?.navigator?.close()
            case .failure:
                // TODO: @juolgon handle error here
                break
            }
        }
    }
}

// MARK: - UI State

extension P2PPaymentsPayoutViewModel {
    struct PayoutInfo {
        let feeText: String
        let standardFundsAvailableText: String
        let instantFundsAvailableText: String
    }

    enum UIState {
        case loading
        case register
        case payout(info: PayoutInfo)

        var showLoadingIndicator: Bool {
            switch self {
            case .loading: return true
            default: return false
            }
        }

        var registerIsHidden: Bool {
            switch self {
            case .register: return false
            default: return true
            }
        }

        var payoutIsHidden: Bool {
            switch self {
            case .payout: return false
            default: return true
            }
        }

        var payoutInfo: PayoutInfo? {
            guard case let .payout(info: info) = self else { return nil }
            return info
        }

        var feeText: String? {
            guard let payoutInfo = payoutInfo else { return nil }
            return payoutInfo.feeText
        }

        var standardFundsAvailableText: String? {
            guard let payoutInfo = payoutInfo else { return nil }
            return payoutInfo.standardFundsAvailableText
        }

        var instantFundsAvailableText: String? {
            guard let payoutInfo = payoutInfo else { return nil }
            return payoutInfo.instantFundsAvailableText
        }
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

    func registerButtonPressed(params: RegistrationParams) {
        registerSeller(params: params)
    }

    func payoutButtonPressed(routingNumber: String, accountNumber: String) {
        requestBankAccountPayout(routingNumber: routingNumber, accountNumber: accountNumber)
    }

    func payoutButtonPressed(name: String,
                             cardNumber: String,
                             cardExpirationMonth: Int,
                             cardExpirationYear: Int,
                             cvc: String) {
        requestCardPayout(name: name,
                          cardNumber: cardNumber,
                          cardExpirationMonth: cardExpirationMonth,
                          cardExpirationYear: cardExpirationYear,
                          cvc: cvc)
    }

    func closeButtonPressed() {
        navigator?.close()
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsPayoutViewModel {
    var showLoadingIndicator: Driver<Bool> { return uiStateRelay.asDriver().map { $0.showLoadingIndicator } }
    var registerIsHidden: Driver<Bool> { return uiStateRelay.asDriver().map { $0.registerIsHidden } }
    var payoutIsHidden: Driver<Bool> { return uiStateRelay.asDriver().map { $0.payoutIsHidden } }
    var feeText: Driver<String?> { return uiStateRelay.asDriver().map { $0.feeText } }
    var standardFundsAvailableText: Driver<String?> { return uiStateRelay.asDriver().map { $0.standardFundsAvailableText } }
    var instantFundsAvailableText: Driver<String?> { return uiStateRelay.asDriver().map { $0.instantFundsAvailableText } }
}
