import Foundation
import LGComponents
import LGCoreKit

class CommunityViewModel: BaseViewModel {

    //weak var navigator:
    let communityRepository: CommunityRepository

    var urlRequest: URLRequest?

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
        super.init()
        setupRequest()
    }

    private func setupRequest() {
        urlRequest = communityRepository.buildCommunityURLRequest()
    }

    func didTapClose() {
        // navigator?.close...
    }
}
