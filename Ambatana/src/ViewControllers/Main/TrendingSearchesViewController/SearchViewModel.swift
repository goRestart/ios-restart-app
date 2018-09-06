import Foundation
import LGComponents
import LGCoreKit

final class SearchViewModel: BaseViewModel {

    weak var navigator: (SearchNavigator & TrendingSearchesNavigator)?
    private let tracker: TrackerProxy
    private let myUserRepository: MyUserRepository

    var wireframe: SearchResultsNavigator?
    
    var onUserSearchCallback: ((SearchType) -> ())?
    
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
                     onUserSearchCallback: ((SearchType) -> ())? = nil) {
        self.init(searchType: searchType,
                  tracker: TrackerProxy.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  onUserSearchCallback: onUserSearchCallback)
    }

    private init(searchType: SearchType?,
                 tracker: TrackerProxy,
                 myUserRepository: MyUserRepository,
                 onUserSearchCallback: ((SearchType) -> ())? = nil) {
        self.searchType = searchType
        self.tracker = tracker
        self.myUserRepository = myUserRepository
        self.onUserSearchCallback = onUserSearchCallback
    }

    func search(_ query: String) {
        guard !query.isEmpty else { return }
        tracker.trackEvent(TrackerEvent.searchStart(myUserRepository.myUser))
        onUserSearchCallback?(.user(query: query))
        wireframe?.cancelSearch()
    }

    func cancel() { wireframe?.cancelSearch() }
}
