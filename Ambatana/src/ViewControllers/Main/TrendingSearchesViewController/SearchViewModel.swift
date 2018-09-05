import Foundation
import LGComponents
import LGCoreKit

final class SearchViewModel: BaseViewModel {

    weak var navigator: (SearchNavigator & TrendingSearchesNavigator)?
    private let tracker: TrackerProxy
    private let myUserRepository: MyUserRepository

    var wireframe: SearchResultsNavigator?
    
    var searchCallback: ((SearchType) -> ())?
    
    private let searchType: SearchType? // The initial search
    var searchString: String? = nil
    var clearTextOnSearch: Bool {
        guard let searchType = searchType else { return false }
        switch searchType {
        case .collection, .feed:
            return true
        case .user, .trending, .suggestive, .lastSearch:
            return false
        }
    }

    convenience init(searchType: SearchType?,
                     searchCallback: ((SearchType) -> ())? = nil) {
        self.init(searchType: searchType,
                  tracker: TrackerProxy.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  searchCallback: searchCallback)
    }

    private init(searchType: SearchType?,
                 tracker: TrackerProxy,
                 myUserRepository: MyUserRepository,
                 searchCallback: ((SearchType) -> ())? = nil) {
        self.searchType = searchType
        self.tracker = tracker
        self.myUserRepository = myUserRepository
        self.searchCallback = searchCallback
    }

    func search(_ query: String) {
        guard !query.isEmpty else { return }
        tracker.trackEvent(TrackerEvent.searchStart(myUserRepository.myUser))
        searchCallback?(.user(query: query))
        wireframe?.cancelSearch()
    }

    func cancel() { wireframe?.cancelSearch() }
}
