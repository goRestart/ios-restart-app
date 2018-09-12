import Foundation
import LGCoreKit
import LGComponents

final class PostAnotherListingViewModel: BaseViewModel {

    var navigator: PostAnotherListingNavigator?

    func postListing() {
        navigator?.postAnotherListing()
    }

    func cancel() {
        navigator?.cancelPost()
    }
}
