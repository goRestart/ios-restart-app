import Foundation

enum RequesterType {
    case nonFilteredFeed, search
}

protocol RequesterFactory: class {
    func buildSearchRequester() -> ListingListRequester
}

final class SearchRequesterFactory: RequesterFactory {
    
    private let dependencyContainer: RequesterDependencyContainer
    
    init(dependencyContainer: RequesterDependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }

    func buildSearchRequester() -> ListingListRequester {
        return build(with: .search)
    }
    
    private func build(with requesterType: RequesterType) -> ListingListRequester {
        let filters = dependencyContainer.filters
        let queryString = dependencyContainer.queryString
        let itemsPerPage = dependencyContainer.itemsPerPage
        switch requesterType {
        case .nonFilteredFeed:
            return FilterListingListRequesterFactory
                .generateDefaultFeedRequester(itemsPerPage: dependencyContainer.itemsPerPage)
        case .search:
            return FilterListingListRequesterFactory
                .generateRequester(withFilters: filters,
                                   queryString: queryString,
                                   itemsPerPage: itemsPerPage)
        }
    }
}

final class RequesterDependencyContainer {
    private(set) var itemsPerPage: Int
    private(set) var filters: ListingFilters
    private(set) var queryString: String?
    
    init(itemsPerPage: Int, filters: ListingFilters, queryString: String?) {
        self.itemsPerPage = itemsPerPage
        self.filters = filters
        self.queryString = queryString
    }
    
    func updateContainer(itemsPerPage: Int, filters: ListingFilters, queryString: String?) {
        self.itemsPerPage = itemsPerPage
        self.filters = filters
        self.queryString = queryString
    }
}
