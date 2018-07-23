import Foundation
import LGComponents
import LGCoreKit

class CommunityViewModel: BaseViewModel {

    //weak var navigator:

    var urlRequest: URLRequest?

    init() {
        // Get request from repository
        urlRequest = URLRequest()
    }

    func didTapClose() {
        // navigator?.close...
    }
}
