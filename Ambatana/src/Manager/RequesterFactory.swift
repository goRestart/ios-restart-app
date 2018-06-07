import Foundation

enum RequesterType: String {
    case nonFilteredFeed, search, similarProducts, combinedSearchAndSimilar
    var identifier: String { return self.rawValue }
}

protocol RequesterFactory: class {
    func buildRequesterList() -> [ListingListRequester]
    func buildIndexedRequesterList() -> [(RequesterType, ListingListRequester)]
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
        case .similarQueries:
            return [.search, .similarProducts, .nonFilteredFeed]
        case .similarQueriesWhenFewResults:
            return [.search, .combinedSearchAndSimilar, .nonFilteredFeed]
        case .alwaysSimilar:
            return [.combinedSearchAndSimilar, .nonFilteredFeed]
        }
    }
    
    func buildIndexedRequesterList() -> [(RequesterType, ListingListRequester)] {
        return requesterTypes.flatMap { type in
            return (type, build(with: type))
        }
    }
    
    func buildRequesterList() -> [ListingListRequester] {
        return requesterTypes.flatMap { build(with: $0) }
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
        case .combinedSearchAndSimilar:
            return FilterListingListRequesterFactory
                .generateCombinedSearchAndSimilar(withFilters: filters,
                                                  queryString: queryString,
                                                  itemsPerPage: itemsPerPage,
                                                  carSearchActive: carSearchActive)
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