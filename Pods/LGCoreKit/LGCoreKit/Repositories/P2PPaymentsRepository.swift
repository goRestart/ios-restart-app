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

public protocol P2PPaymentsRepository {
    func showOffer(id: String, completion: ShowP2PPaymentOfferCompletion?)
    func createOffer(params: P2PPaymentCreateOfferParams, completion: CreateP2PPaymentOfferCompletion?)
    func calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams, completion: CalculateP2PPaymentOfferFeesCompletion?)
    func changeOfferStatus(offerId: String, status: P2PPaymentOfferStatus, completion: ChangeP2PPaymentOfferStatusCompletion?)
}
