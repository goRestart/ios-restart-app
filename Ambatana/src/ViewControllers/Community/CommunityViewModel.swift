import Foundation
import LGComponents
import LGCoreKit

class CommunityViewModel: BaseViewModel {

    weak var navigator: CommunityTabNavigator?
    private let communityRepository: CommunityRepository

    var urlRequest: URLRequest?
    var showNavBar: Bool
    var showCloseButton: Bool

    init(communityRepository: CommunityRepository, source: CommunitySource) {
        self.communityRepository = communityRepository
        self.showNavBar = source == .navBar
        self.showCloseButton = source == .navBar
        super.init()
        setupRequest()
    }

    private func setupRequest() {
        urlRequest = communityRepository.buildCommunityURLRequest()
    }

    func didTapClose() {
        navigator?.closeCommunity()
    }
}
