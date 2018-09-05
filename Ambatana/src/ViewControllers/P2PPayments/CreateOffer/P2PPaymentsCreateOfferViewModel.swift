import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsCreateOfferViewModel: BaseViewModel {
    var navigator: P2PPaymentsMakeAnOfferNavigator?
    private let chatConversation: ChatConversation
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let myUserRepository: MyUserRepository
    fileprivate let currencyHelper = Core.currencyHelper

    private let listingImageViewURLRelay = BehaviorRelay<URL?>(value: nil)
    private let listingTitleRelay = BehaviorRelay<String?>(value: nil)
    private let uiStateRelay = BehaviorRelay<UIState>(value: .loading)
    private let paymentButtonStateRelay = BehaviorRelay<PaymentButtonState>(value: .buy)
    private let offerFeesRelay = BehaviorRelay<P2PPaymentOfferFees?>(value: nil)
    private let currencyCodeRelay = BehaviorRelay<String?>(value: nil)
    private let offerAmountRelay = BehaviorRelay<Decimal>(value: 0)

    convenience init(chatConversation: ChatConversation) {
        self.init(chatConversation: chatConversation,
                  p2pPaymentsRepository: Core.p2pPaymentsRepository,
                  myUserRepository: Core.myUserRepository)
    }

    init(chatConversation: ChatConversation,
         p2pPaymentsRepository: P2PPaymentsRepository,
         myUserRepository: MyUserRepository) {
        self.chatConversation = chatConversation
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.myUserRepository = myUserRepository
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        setup()
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
        uiStateRelay.accept(.loading)
        guard
            let currency = chatConversation.listing?.currency,
            offerAmountRelay.value > 0 else {
                uiStateRelay.accept(.changeOffer)
                return
        }
        let params = P2PPaymentCalculateOfferFeesParams(amount: offerAmountRelay.value, currency: currency)
        p2pPaymentsRepository.calculateOfferFees(params: params) { [weak self] result in
            switch result {
            case .success(let offerFees):
                self?.updateOfferFees(offerFees)
            case .failure(_):
                self?.uiStateRelay.accept(.changeOffer)
            }
        }
    }

    private func updateOfferFees(_ offerFees: P2PPaymentOfferFees) {
        offerFeesRelay.accept(offerFees)
        uiStateRelay.accept(.buy)
    }
}

// MARK: - Inner types

extension P2PPaymentsCreateOfferViewModel {
    enum UIState {
        case loading, buy, changeOffer
    }

    enum PaymentButtonState {
        case setup, buy
    }
}

// MARK: - UI Actions

extension P2PPaymentsCreateOfferViewModel {
    func closeButtonPressed() {
        navigator?.closeOnboarding()
    }

    func changeOfferButtonPressed() {
        uiStateRelay.accept(.changeOffer)
    }

    func changeOfferDoneButtonPressed(newValue: Decimal) {
        offerAmountRelay.accept(newValue)
        calculateFees()
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
}
