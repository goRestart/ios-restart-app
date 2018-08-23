import LGCoreKit

final class LGFeedBadgingSynchronizer: FeedBadgingSynchronizer {
    
    private let locationManager: LocationManager
    private let listingRepository: ListingRepository
    private let keyValueStorage: KeyValueStorage
    private let notificationsManager: NotificationsManager
    
    let badgeNumber: Int
    
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(locationManager: Core.locationManager,
                  listingRepository: Core.listingRepository,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  appIconBadgeNumber: UIApplication.shared.applicationIconBadgeNumber)
    }
    
    init(locationManager: LocationManager,
         listingRepository: ListingRepository,
         keyValueStorage: KeyValueStorage,
         notificationsManager: NotificationsManager,
         appIconBadgeNumber: Int) {
        self.locationManager = locationManager
        self.listingRepository = listingRepository
        self.keyValueStorage = keyValueStorage
        self.notificationsManager = notificationsManager
        self.badgeNumber = appIconBadgeNumber
    }
    
    
    // MARK: - Badge checker
    
    func retrieveRecentListings(completion: RecentItemsCompletion?) {
        guard let lastSessionDate = keyValueStorage[.lastSessionDate] else { return }
        let previousSessionLongerThan1Hour = Date().timeIntervalSince(lastSessionDate) > TimeInterval.make(hours: 1)
        let hasAppIconBadge = badgeNumber > 0
        guard hasAppIconBadge, previousSessionLongerThan1Hour else { return }
        var params = RetrieveListingParams()
        if let currentLocation = locationManager.currentLocation {
            params.coordinates = LGLocationCoordinates2D(location: currentLocation)
        }
        params.timeCriteria = ListingTimeCriteria.date(date: lastSessionDate)
        
        listingRepository.index(params) { [weak self] result in
            guard let recentListings = result.value, !recentListings.isEmpty else {
                completion?([])
                return
            }
            self?.showBadge()
            completion?(recentListings)
        }
    }
    
    
    // MARK: - Visibility
    
    func showBadge() {
        notificationsManager.showEngagementBadge()
    }
    
    func hideBadge() {
        notificationsManager.hideEngagementBadge()
    }
}