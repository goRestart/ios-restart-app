import LGCoreKit
import RxSwift

protocol InterestedHandleable {
    func retrieveInterestedActionFor(_ listing: Listing, userListing: LocalUser?) -> InterestedAction
    func interestedActionFor(_ listing: Listing,
                             userListing: LocalUser?,
                             stateCompletion: @escaping (InterestedState) -> Void,
                             actionCompletion: @escaping (InterestedAction) -> Void)
    func handleCancellableInterestedAction(_ listing: Listing, timer: Observable<Any>, completion: @escaping (InterestedState) -> Void)
}
