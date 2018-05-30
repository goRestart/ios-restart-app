import Foundation

enum RequesterType: String {
    case nonFilteredFeed, search, similarProducts
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
        switch requesterType {
        case .nonFilteredFeed:
            return FilterListingListRequesterFactory
                .generateDefaultFeedRequester(itemsPerPage: dependencyContainer.itemsPerPage)
        case .search:
            return FilterListingListRequesterFactory
                .generateRequester(withFilters: dependencyContainer.filters,
                                   queryString: dependencyContainer.queryString,
                                   itemsPerPage: dependencyContainer.itemsPerPage,
                                   carSearchActive: dependencyContainer.carSearchActive)
        case .similarProducts:
            // FIXME: change to similar Products requester once it is created
            return FilterListingListRequesterFactory
                .generateDefaultFeedRequester(itemsPerPage: dependencyContainer.itemsPerPage)
        }
    }
}

final class RequesterDependencyContainer {
    private(set) var itemsPerPage: Int
    private(set) var filters: ListingFilters
    private(set) var queryString: String?
    private(set) var carSearchActive: Bool
    
    init(itemsPerPage: Int, filters: ListingFilters, queryString: String?, carSearchActive: Bool) {
        self.itemsPerPage = itemsPerPage
        self.filters = filters
        self.queryString = queryString
        self.carSearchActive = carSearchActive
    }
    
    func updateContainer(itemsPerPage: Int, filters: ListingFilters, queryString: String?, carSearchActive: Bool) {
        self.itemsPerPage = itemsPerPage
        self.filters = filters
        self.queryString = queryString
        self.carSearchActive = carSearchActive
    }
}
