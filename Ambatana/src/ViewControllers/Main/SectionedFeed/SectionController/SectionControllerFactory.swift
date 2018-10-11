import IGListKit
import LGComponents
import GoogleMobileAds

typealias FeedDelegate = PushPermissionsPresenterDelegate &
    ListingActionDelegate &
    SelectedForYouDelegate &
    LocationEditable &
    RetryFooterDelegate &
    HorizontalSectionDelegate &
    AdUpdated &
    CategoriesHeaderCollectionViewDelegate

final class SectionControllerFactory: NSObject {
    
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
        case let bubbleBarModel as DiffableBox<BubbleBarSectionModel>:
            let categoryBubbleController = CategoryBubbleSectionController(categories: bubbleBarModel.value.items)
            categoryBubbleController.delegate = delegate
            return categoryBubbleController
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
            let bannerSectionController = BannerSectionController(tracker: tracker,
                                                                  adUnitId: EnvironmentProxy.sharedInstance.sectionedFeedAdUnitForUS,
                                                                  rootViewController: rootViewController ?? UIViewController())
            bannerSectionController.delegate = delegate
            return bannerSectionController
        case .native:
            var feedAdUnitId = featureFlags.feedAdUnitId
            var adTypes: [GADAdLoaderAdType] = [.nativeContent]
            if featureFlags.appInstallAdsInFeed.isActive {
                feedAdUnitId = featureFlags.appInstallAdsInFeedAdUnit
                adTypes.append(.nativeAppInstall)
            }
            if featureFlags.googleUnifiedNativeAds.isActive {
                adTypes = [.unifiedNative]
            }
            var bidder: PMBidder? = nil
            if featureFlags.polymorphFeedAdsUSA.isActive {
                feedAdUnitId = EnvironmentProxy.sharedInstance.feedAdUnitIdPolymorphUSA
                bidder = PMBidder.init(pmAdUnitID: EnvironmentProxy.sharedInstance.polymorphAdUnit)
            }

            let adsSectionController = AdsSectionController(adWidth: ListingCellSizeMetrics(numberOfColumns: waterfallColumnCount).cellWidth,
                                                            adUnitId: feedAdUnitId ?? "",
                                                            rootViewController: rootViewController ?? UIViewController(),
                                                            adTypes: adTypes,
                                                            bidder: bidder)
            adsSectionController.delegate = delegate
            adsSectionController.unifiedAdsDelegate = self
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

extension SectionControllerFactory: GADUnifiedNativeAdDelegate {
    
    public func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
        guard let position = nativeAd.position else { return }
        let hasVideoContent = nativeAd.videoController?.hasVideoContent()
        var adType = EventParameterAdType.adx
        if let extraAssets = nativeAd.extraAssets,
            let network = extraAssets[SharedConstants.adNetwork] as? String,
            network == EventParameterAdType.polymorph.stringValue {
            adType = .polymorph
        }
        let trackerEvent = TrackerEvent.adTapped(listingId: nil,
                                                 adType: adType,
                                                 isMine: .notAvailable,
                                                 queryType: nil,
                                                 query: nil,
                                                 willLeaveApp: .trueParameter,
                                                 hasVideoContent: EventParameterBoolean.init(bool: hasVideoContent),
                                                 typePage: .listingList,
                                                 categories: nil,
                                                 feedPosition: .position(index: position))
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
