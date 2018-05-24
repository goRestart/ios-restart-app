import LGCoreKit
import LGComponents

class MostSearchedItemsListViewModel: BaseViewModel {
    
    weak var navigator: MostSearchedItemsNavigator?
    let isSearchEnabled: Bool
    fileprivate let locationManager: LocationManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let postingSource: PostingSource
    
    let mostSearchedItems: [LocalMostSearchedItem]
    var titleString: String {
        if let city = locationManager.currentLocation?.postalAddress?.city, !city.isEmpty {
            return R.Strings.trendingItemsViewTitle(city)
        } else {
            return R.Strings.trendingItemsViewTitleNoLocation
        }
    }
    
    
    // MARK: - Lifecycle
    
    convenience init(isSearchEnabled: Bool, locationManager: LocationManager, postingSource: PostingSource) {
        self.init(featureFlags: FeatureFlags.sharedInstance,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  isSearchEnabled: isSearchEnabled,
                  locationManager: locationManager,
                  postingSource: postingSource)
    }
    
    init(featureFlags: FeatureFlaggeable,
         notificationsManager: NotificationsManager,
         keyValueStorage: KeyValueStorage,
         isSearchEnabled: Bool,
         locationManager: LocationManager,
         postingSource: PostingSource) {
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.isSearchEnabled = isSearchEnabled
        self.locationManager = locationManager
        self.postingSource = postingSource
        mostSearchedItems = LocalMostSearchedItem.allValues
        super.init()
        
        let isShowingSellBadge = featureFlags.mostSearchedDemandedItems == .cameraBadge &&
            !keyValueStorage[.mostSearchedItemsCameraBadgeAlreadyShown]
        if isShowingSellBadge {
            keyValueStorage[.mostSearchedItemsCameraBadgeAlreadyShown] = true
            notificationsManager.clearNewSellFeatureIndicator()
        }
    }
    
    
    // MARK: - Navigation
    
    func closeButtonPressed() {
        navigator?.cancel()
    }
    
    func searchButtonAction(listingTitle: String) {
        navigator?.openSearchFor(listingTitle: listingTitle)
    }
    
    func postButtonAction(item: LocalMostSearchedItem) {
        navigator?.openSell(mostSearchedItem: item, source: postingSource)
    }
    
    
    // MARK: - Most Searched Items data
    
    func itemAtIndex(_ index: Int) -> LocalMostSearchedItem {
        return mostSearchedItems[index]
    }
}
