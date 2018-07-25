import Foundation
import LGComponents
import LGCoreKit

final class SearchViewModel: BaseViewModel {

    weak var navigator: (SearchNavigator & TrendingSearchesNavigator)?
    private let tracker: TrackerProxy
    private let myUserRepository: MyUserRepository

    private let searchType: SearchType? // The initial search
    var searchString: String? = nil
    var clearTextOnSearch: Bool {
        guard let searchType = searchType else { return false }
        switch searchType {
        case .collection:
            return true
        case .user, .trending, .suggestive, .lastSearch:
            return false
        }
    }

    convenience init(searchType: SearchType?) {
        self.init(searchType: searchType,
                  tracker: TrackerProxy.sharedInstance,
                  myUserRepository: Core.myUserRepository)
    }

    private init(searchType: SearchType?, tracker: TrackerProxy, myUserRepository: MyUserRepository) {
        self.searchType = searchType
        self.tracker = tracker
        self.myUserRepository = myUserRepository
    }

    func search(_ query: String) {
        guard !query.isEmpty else { return }
        tracker.trackEvent(TrackerEvent.searchStart(myUserRepository.myUser))
        navigator?.openSearchResults(with: .user(query: query))
    }

    func cancel() {
        navigator?.cancelSearch()
    }
}
