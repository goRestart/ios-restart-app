import Foundation
import Result

public typealias CreateP2PPaymentOfferResult = Result<String, RepositoryError>
public typealias CreateP2PPaymentOfferCompletion = (CreateP2PPaymentOfferResult) -> Void

public typealias CalculateP2PPaymentOfferFeesResult = Result<P2PPaymentOfferFees, RepositoryError>
public typealias CalculateP2PPaymentOfferFeesCompletion = (CalculateP2PPaymentOfferFeesResult) -> Void

public typealias ShowP2PPaymentOfferResult = Result<P2PPaymentOffer, RepositoryError>
public typealias ShowP2PPaymentOfferCompletion = (ShowP2PPaymentOfferResult) -> Void

public typealias ChangeP2PPaymentOfferStatusResult = Result<Void, RepositoryError>
public typealias ChangeP2PPaymentOfferStatusCompletion = (ChangeP2PPaymentOfferStatusResult) -> Void

public typealias GetP2PPaymentPaymentStateResult = Result<P2PPaymentState, RepositoryError>
public typealias GetP2PPaymentPaymentStateCompletion = (GetP2PPaymentPaymentStateResult) -> Void

public typealias GetP2PPaymentPayCodeResult = Result<String, RepositoryError>
public typealias GetP2PPaymentPayCodeCompletion = (GetP2PPaymentPayCodeResult) -> Void

public typealias UseP2PPaymentPayCodeResult = Result<Void, RepositoryError>
public typealias UseP2PPaymentPayCodeCompletion = (UseP2PPaymentPayCodeResult) -> Void

public typealias ShowP2PPaymentSellerResult = Result<P2PPaymentSeller, RepositoryError>
public typealias ShowP2PPaymentSellerCompletion = (ShowP2PPaymentSellerResult) -> Void

public typealias UpdateP2PPaymentSellerResult = Result<Void, RepositoryError>
public typealias UpdateP2PPaymentSellerCompletion = (UpdateP2PPaymentSellerResult) -> Void

public typealias CalculateP2PPaymentPayoutPriceBreakdownResult = Result<P2PPaymentPayoutPriceBreakdown, RepositoryError>
public typealias CalculateP2PPaymentPayoutPriceBreakdownCompletion = (CalculateP2PPaymentPayoutPriceBreakdownResult) -> Void

public typealias RequestP2PPaymentPayoutResult = Result<String, RepositoryError>
public typealias RequestP2PPaymentPayoutCompletion = (RequestP2PPaymentPayoutResult) -> Void

public protocol P2PPaymentsRepository {
    var shouldRefreshChatMessages: Bool { get }
    func markChatMessagesAsRefreshed()
    func showOffer(id: String, completion: ShowP2PPaymentOfferCompletion?)
    func createOffer(params: P2PPaymentCreateOfferParams, completion: CreateP2PPaymentOfferCompletion?)
    func calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams, completion: CalculateP2PPaymentOfferFeesCompletion?)
    func changeOfferStatus(offerId: String, status: P2PPaymentOfferStatus, completion: ChangeP2PPaymentOfferStatusCompletion?)
    func getPaymentState(params: P2PPaymentStateParams, completion: GetP2PPaymentPaymentStateCompletion?)
    func getPayCode(offerId: String, completion: GetP2PPaymentPayCodeCompletion?)
    func usePayCode(payCode: String, offerId: String, completion: UseP2PPaymentPayCodeCompletion?)
    func showSeller(id: String, completion: ShowP2PPaymentSellerCompletion?)
    func updateSeller(params: P2PPaymentCreateSellerParams, completion: UpdateP2PPaymentSellerCompletion?)
    func calculatePayoutPriceBreakdown(amount: Decimal, currency: Currency, completion: CalculateP2PPaymentPayoutPriceBreakdownCompletion?)
    func requestPayout(params: P2PPaymentRequestPayoutParams, completion: RequestP2PPaymentPayoutCompletion?)
}
