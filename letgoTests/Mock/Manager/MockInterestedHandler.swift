@testable import LetGoGodMode
import LGCoreKit
import RxSwift

final class MockInterestedHandler: InterestedHandleable {
    func retrieveInterestedActionFor(_ listing: Listing, userListing: LocalUser?) -> InterestedAction {
        return .triggerInterestedAction
    }
    func interestedActionFor(_ listing: Listing, userListing: LocalUser?, stateCompletion: @escaping (InterestedState) -> Void, actionCompletion: @escaping (InterestedAction) -> Void) { }
    func handleCancellableInterestedAction(_ listing: Listing, timer: Observable<Any>, completion: @escaping (InterestedState) -> Void) {}
}
