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

protocol P2PPaymentsDataSource {
    func showOffer(id: String, completion: P2PPaymentsDataSourceOfferCompletion?)
    func createOffer(params: P2PPaymentCreateOfferParams, completion: P2PPaymentsDataSourceCreateOfferCompletion?)
    func calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams, completion: P2PPaymentsDataSourceCalculateOfferFeesCompletion?)
    func changeOfferStatus(offerId: String, status: P2PPaymentOfferStatus, completion: P2PPaymentsDataSourceEmptyCompletion?)
}
