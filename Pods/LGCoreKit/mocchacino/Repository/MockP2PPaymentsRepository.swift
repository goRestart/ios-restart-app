import Result

open class MockP2PPaymentsRepository: P2PPaymentsRepository {

    public var createOfferResult: CreateP2PPaymentOfferResult!
    public var offerResult: ShowP2PPaymentOfferResult!
    public var calculateOfferFeesResult :CalculateP2PPaymentOfferFeesResult!
    public var changeOfferStatusResult: ChangeP2PPaymentOfferStatusResult!
    public var getPaymentStateResult: GetP2PPaymentPaymentStateResult!
    public var getPayCodeResult: GetP2PPaymentPayCodeResult!
    public var usePayCodeResult: UseP2PPaymentPayCodeResult!
    public var showSellerResult: ShowP2PPaymentSellerResult!
    public var updateSellerResult: UpdateP2PPaymentSellerResult!
    public var calculatePayoutPriceBreakdownResult: CalculateP2PPaymentPayoutPriceBreakdownResult!
    public var requestPayoutResult: RequestP2PPaymentPayoutResult!


    // MARK: - Lifecycle

    required public init() {}


    // MARK: - P2PPaymentsRepository

    public var shouldRefreshChatMessages: Bool = false

    public func markChatMessagesAsRefreshed() {
        shouldRefreshChatMessages = false
    }

    public func showOffer(id: String, completion: ShowP2PPaymentOfferCompletion?) {
        delay(result: offerResult, completion: completion)
    }

    public func createOffer(params: P2PPaymentCreateOfferParams, completion: CreateP2PPaymentOfferCompletion?) {
        delay(result: createOfferResult, completion: completion)
    }

    public func calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams, completion: CalculateP2PPaymentOfferFeesCompletion?) {
        delay(result: calculateOfferFeesResult, completion: completion)
    }

    public func changeOfferStatus(offerId: String, status: P2PPaymentOfferStatus, completion: ChangeP2PPaymentOfferStatusCompletion?) {
        delay(result: changeOfferStatusResult, completion: completion)
    }

    public func getPaymentState(params: P2PPaymentStateParams, completion: GetP2PPaymentPaymentStateCompletion?) {
        delay(result: getPaymentStateResult, completion: completion)
    }

    public func getPayCode(offerId: String, completion: GetP2PPaymentPayCodeCompletion?) {
        delay(result: getPayCodeResult, completion: completion)
    }

    public func usePayCode(payCode: String, offerId: String, completion: UseP2PPaymentPayCodeCompletion?) {
        delay(result: usePayCodeResult, completion: completion)
    }

    public func showSeller(id: String, completion: ShowP2PPaymentSellerCompletion?) {
        delay(result: showSellerResult, completion: completion)
    }

    public func updateSeller(params: P2PPaymentCreateSellerParams, completion: UpdateP2PPaymentSellerCompletion?) {
        delay(result: updateSellerResult, completion: completion)
    }

    public func calculatePayoutPriceBreakdown(amount: Decimal, currency: Currency, completion: CalculateP2PPaymentPayoutPriceBreakdownCompletion?) {
        delay(result: calculatePayoutPriceBreakdownResult, completion: completion)
    }
    
    public func requestPayout(params: P2PPaymentRequestPayoutParams, completion: RequestP2PPaymentPayoutCompletion?) {
        delay(result: requestPayoutResult, completion: completion)
    }
}
