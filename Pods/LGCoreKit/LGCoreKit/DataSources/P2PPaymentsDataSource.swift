import Foundation
import Result

typealias P2PPaymentOfferId = String

typealias P2PPaymentsDataSourceOfferResult = Result<P2PPaymentOffer, ApiError>
typealias P2PPaymentsDataSourceOfferCompletion = (P2PPaymentsDataSourceOfferResult) -> Void

typealias P2PPaymentsDataSourceCreateOfferResult = Result<P2PPaymentOfferId, ApiError>
typealias P2PPaymentsDataSourceCreateOfferCompletion = (P2PPaymentsDataSourceCreateOfferResult) -> Void

typealias P2PPaymentsDataSourceCalculateOfferFeesResult = Result<P2PPaymentOfferFees, ApiError>
typealias P2PPaymentsDataSourceCalculateOfferFeesCompletion = (P2PPaymentsDataSourceCalculateOfferFeesResult) -> Void

typealias P2PPaymentsDataSourceEmptyResult = Result<Void, ApiError>
typealias P2PPaymentsDataSourceEmptyCompletion = (P2PPaymentsDataSourceEmptyResult) -> Void

typealias P2PPaymentsDataSourcePaymentStateResult = Result<P2PPaymentState, ApiError>
typealias P2PPaymentsDataSourcePaymentStateCompletion = (P2PPaymentsDataSourcePaymentStateResult) -> Void

typealias P2PPaymentsDataSourcePayCodeResult = Result<String, ApiError>
typealias P2PPaymentsDataSourcePayCodeCompletion = (P2PPaymentsDataSourcePayCodeResult) -> Void

typealias P2PPaymentsDataSourceShowSellerResult = Result<P2PPaymentSeller, ApiError>
typealias P2PPaymentsDataSourceShowSellerCompletion = (P2PPaymentsDataSourceShowSellerResult) -> Void

typealias P2PPaymentsDataSourcePayoutPriceBreakdownResult = Result<P2PPaymentPayoutPriceBreakdown, ApiError>
typealias P2PPaymentsDataSourcePayoutPriceBreakdownCompletion = (P2PPaymentsDataSourcePayoutPriceBreakdownResult) -> Void

typealias P2PPaymentsDataSourceRequestPayoutResult = Result<String, ApiError>
typealias P2PPaymentsDataSourceRequestPayoutCompletion = (P2PPaymentsDataSourceRequestPayoutResult) -> Void

protocol P2PPaymentsDataSource {
    func showOffer(id: String, completion: P2PPaymentsDataSourceOfferCompletion?)
    func createOffer(params: P2PPaymentCreateOfferParams, completion: P2PPaymentsDataSourceCreateOfferCompletion?)
    func calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams, completion: P2PPaymentsDataSourceCalculateOfferFeesCompletion?)
    func changeOfferStatus(offerId: String, status: P2PPaymentOfferStatus, completion: P2PPaymentsDataSourceEmptyCompletion?)
    func getPaymentState(params: P2PPaymentStateParams, completion: P2PPaymentsDataSourcePaymentStateCompletion?)
    func getPayCode(offerId: String, completion: P2PPaymentsDataSourcePayCodeCompletion?)
    func usePayCode(payCode: String, offerId: String, completion: P2PPaymentsDataSourceEmptyCompletion?)
    func showSeller(id: String, completion: P2PPaymentsDataSourceShowSellerCompletion?)
    func updateSeller(params: P2PPaymentCreateSellerParams, completion: P2PPaymentsDataSourceEmptyCompletion?)
    func calculatePayoutPriceBreakdown(amount: Decimal, currency: Currency, completion: P2PPaymentsDataSourcePayoutPriceBreakdownCompletion?)
    func requestPayout(params: P2PPaymentRequestPayoutParams, completion: P2PPaymentsDataSourceRequestPayoutCompletion?)
}
