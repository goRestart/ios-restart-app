import Foundation
import LGComponents
import LGCoreKit

class CommunityViewModel: BaseViewModel {

    //weak var navigator:
    private let communityRepository: CommunityRepository

    let showTabBar: Bool
    var urlRequest: URLRequest?

    init(communityRepository: CommunityRepository,
         source: CommunitySource) {
        self.communityRepository = communityRepository
        self.showTabBar = source == .tabbar
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
