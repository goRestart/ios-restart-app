import IGListKit

typealias FeedDelegate = PushPermissionsPresenterDelegate &
    ListingActionDelegate &
    SelectedForYouDelegate &
    LocationEditable &
    RetryFooterDelegate &
    HorizontalSectionDelegate &
    AdUpdated

final class SectionControllerFactory {
    
    private let waterfallColumnCount: Int
    private let featureFlags: FeatureFlaggeable
    private let tracker: Tracker
    private let pushPermissionsManager: PushPermissionsManager
    
    weak var delegate: FeedDelegate?
    weak var rootViewController: UIViewController?
    
    private var shouldShowEditOnLocationHeader: Bool
    
    init(waterfallColumnCount: Int,
         featureFlags: FeatureFlaggeable,
         tracker: Tracker,
         pushPermissionsManager: PushPermissionsManager,
         shouldShowEditOnLocationHeader: Bool = true) {
        self.waterfallColumnCount = waterfallColumnCount
        self.featureFlags = featureFlags
        self.tracker = tracker
        self.pushPermissionsManager = pushPermissionsManager
        self.shouldShowEditOnLocationHeader = shouldShowEditOnLocationHeader
    }
    
    func make(for object: Any) -> ListSectionController {
        
        switch object {
        case is DiffableBox<ListingSectionModel>:
            let horizontalSectionController = HorizontalSectionController()
            horizontalSectionController.listingActionDelegate = delegate
            horizontalSectionController.delegate = delegate
            return horizontalSectionController
        case let staticSectionString as String:
            guard let staticSectionType = StaticSectionType(rawValue: staticSectionString) else { return ListSectionController() }
            return staticSectionController(for: staticSectionType)
        case is SelectedForYou:
            let selectedForYouController = SelectedForYouSectionController()
            selectedForYouController.selectedForYouDelegate = delegate
            return selectedForYouController
        case is DiffableBox<FeedListingData>:
            let productListingViewModel = ProductListingViewModel(numberOfColumns: waterfallColumnCount)
            let sectionController = ProductListingSectionController(productListingViewModel: productListingViewModel)
            sectionController.listingActionDelegate = delegate
            return sectionController
        case is LocationData:
            let locationEditor = LocationSectionController(
                shouldShowEdit: shouldShowEditOnLocationHeader
            )
            locationEditor.locationEditable = delegate
            return locationEditor
        case is DiffableBox<ListingRetrievalState>:
                let statusIndicatorLoader = StatusIndicationSectionController()
                statusIndicatorLoader.retryFooterDelegate = delegate
                return statusIndicatorLoader
        case let adDiff as DiffableBox<AdData>:
            return makeAdController(withAdData: adDiff.value)
        default:
            return ListSectionController()
        }
    }
    
    private func makeAdController(withAdData adData: AdData) -> ListSectionController {
        switch adData.type {
        case .banner:
            let bannerSectionController = BannerSectionController(tracker: tracker)
            bannerSectionController.delegate = delegate
            return bannerSectionController
        case .native:
            let appAdUnit = featureFlags.appInstallAdsInFeedAdUnit
            let adsSectionController = AdsSectionController(adWidth: ListingCellSizeMetrics(numberOfColumns: waterfallColumnCount).cellWidth,
                                                            adUnitId: appAdUnit ?? "",
                                                            rootViewController: rootViewController ?? UIViewController(),
                                                            adTypes: [.nativeContent, .nativeAppInstall])
            adsSectionController.delegate = delegate
            return adsSectionController
        }
    }
    
    private func staticSectionController(for type: StaticSectionType) -> ListSectionController {
        switch type {
        case .pushBanner:
            let pushTracker = PushPermissionsTracker(tracker: tracker,
                                                     pushPermissionsManager: pushPermissionsManager)
            let pushMessageSectionController = PushMessageSectionController(pushPermissionTracker: pushTracker)
            pushMessageSectionController.delegate = delegate
            return pushMessageSectionController
        }
    }
    
    
}
