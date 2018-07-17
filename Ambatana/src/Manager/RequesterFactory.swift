import Foundation

enum RequesterType: String {
    case nonFilteredFeed, search, similarProducts
    var identifier: String { return self.rawValue }
}

protocol RequesterFactory: class {
    func buildRequesterList() -> [ListingListRequester]
    func buildIndexedRequesterList() -> [(RequesterType, ListingListRequester)]
    func buildRecentListingsRequester() -> RecentListingsRequester
}

final class SearchRequesterFactory: RequesterFactory {
    
    private let dependencyContainer: RequesterDependencyContainer
    private let featureFlags: FeatureFlaggeable
    
    init(dependencyContainer: RequesterDependencyContainer,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.dependencyContainer = dependencyContainer
        self.featureFlags = featureFlags
    }

    private var requesterTypes: [RequesterType] {
        switch featureFlags.emptySearchImprovements {
        case .baseline, .control:
            return [.search]
        case .popularNearYou:
            return [.search, .nonFilteredFeed]
        case .similarQueries, .similarQueriesWhenFewResults, .alwaysSimilar:
            return [.search, .similarProducts, .nonFilteredFeed]
        }
    }
    
    func buildIndexedRequesterList() -> [(RequesterType, ListingListRequester)] {
        return requesterTypes.compactMap { type in
            return (type, build(with: type))
        }
    }
    
    func buildRequesterList() -> [ListingListRequester] {
        return requesterTypes.compactMap { build(with: $0) }
    }
    
    func buildRecentListingsRequester() -> RecentListingsRequester {
        return RecentListingsRequester()
    }
    
    private func build(with requesterType: RequesterType) -> ListingListRequester {
        let filters = dependencyContainer.filters
        let queryString = dependencyContainer.queryString
        let itemsPerPage = dependencyContainer.itemsPerPage
        let carSearchActive = dependencyContainer.carSearchActive
        switch requesterType {
        case .nonFilteredFeed:
            return FilterListingListRequesterFactory
                .generateDefaultFeedRequester(itemsPerPage: dependencyContainer.itemsPerPage)
        case .search:
            return FilterListingListRequesterFactory
                .generateRequester(withFilters: filters,
                                   queryString: queryString,
                                   itemsPerPage: itemsPerPage,
                                   carSearchActive: carSearchActive)
        case .similarProducts:
            return FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                queryString: queryString,
                                                                itemsPerPage: itemsPerPage,
                                                                carSearchActive: carSearchActive,
                                                                similarSearchActive: dependencyContainer.similarSearchActive)

        }
    }
}

final class RequesterDependencyContainer {
    private(set) var itemsPerPage: Int
    private(set) var filters: ListingFilters
    private(set) var queryString: String?
    private(set) var carSearchActive: Bool
    private(set) var similarSearchActive: Bool
    
    init(itemsPerPage: Int, filters: ListingFilters, queryString: String?, carSearchActive: Bool, similarSearchActive: Bool) {
        self.itemsPerPage = itemsPerPage
        self.filters = filters
        self.queryString = queryString
        self.carSearchActive = carSearchActive
        self.similarSearchActive = similarSearchActive
    }
    
    func updateContainer(itemsPerPage: Int, filters: ListingFilters, queryString: String?, carSearchActive: Bool,  similarSearchActive: Bool) {
        self.itemsPerPage = itemsPerPage
        self.filters = filters
        self.queryString = queryString
        self.carSearchActive = carSearchActive
        self.similarSearchActive = similarSearchActive
    }
}
