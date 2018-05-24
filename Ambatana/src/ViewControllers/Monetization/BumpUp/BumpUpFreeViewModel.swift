import Foundation
import LGCoreKit
import LGComponents

class BumpUpFreeViewModel: BaseViewModel {
    let shareTypes: [ShareType]

    let listing: Listing
    private let letgoItemId: String?
    private let storeProductId: String?
    private let typePage: EventParameterTypePage?
    let socialSharer: SocialSharer?
    private let tracker: Tracker

    weak var delegate: BaseViewModelDelegate?
    weak var navigator: BumpUpNavigator?

    var socialMessage: SocialMessage
    var title: String
    var subtitle: String

    private var purchasesShopper: PurchasesShopper?

    convenience init(listing: Listing,
                     socialMessage: SocialMessage,
                     letgoItemId: String?,
                     storeProductId: String?,
                     typePage: EventParameterTypePage?) {
        self.init(listing: listing,
                  socialSharer: SocialSharer(),
                  socialMessage: socialMessage,
                  letgoItemId: letgoItemId,
                  storeProductId: storeProductId, 
                  typePage: typePage,
                  locationManager: Core.locationManager,
                  tracker: TrackerProxy.sharedInstance,
                  purchasesShopper: LGPurchasesShopper.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(listing: Listing,
         socialSharer: SocialSharer,
         socialMessage: SocialMessage,
         letgoItemId: String?,
         storeProductId: String?,
         typePage: EventParameterTypePage?,
         locationManager: LocationManager,
         tracker: Tracker,
         purchasesShopper: PurchasesShopper?,
         featureFlags: FeatureFlaggeable) {
        self.listing = listing
        self.socialSharer = socialSharer
        self.tracker = tracker
        self.socialMessage = socialMessage
        self.purchasesShopper = purchasesShopper
        self.shareTypes = BumpUpFreeViewModel.computeShareTypes(featureFlags: featureFlags)
        self.letgoItemId = letgoItemId
        self.storeProductId = storeProductId
        self.typePage = typePage
        self.title = R.Strings.bumpUpViewFreeTitle
        self.subtitle = R.Strings.bumpUpViewFreeSubtitle

        super.init()

        self.socialSharer?.delegate = self
    }

    func viewDidApear() {
        let trackerEvent = TrackerEvent.bumpBannerInfoShown(type: EventParameterBumpUpType(bumpType: .free),
                                                            listingId: listing.objectId,
                                                            storeProductId: storeProductId,
                                                            typePage: typePage,
                                                            isBoost: EventParameterBoolean.falseParameter)
        tracker.trackEvent(trackerEvent)
    }


    // MARK: - Public Methods

    func closeActionPressed() {
        navigator?.bumpUpDidCancel()
    }

    func close(withCompletion completion: (() -> Void)?) {
        navigator?.bumpUpDidFinish(completion: completion)
    }
    
    
    // MARK: - Private methods
    
    private static func computeShareTypes(featureFlags: FeatureFlaggeable) -> [ShareType] {
        var shareTypes = featureFlags.shareTypes.filter { SocialSharer.canShareIn($0) }
        let maxButtonCount = 3
        if shareTypes.count > maxButtonCount {
            shareTypes = Array(shareTypes[0..<maxButtonCount])
        }
        shareTypes.append(.native(restricted: true))
        return shareTypes
    }
}


// MARK: - SocialShareFacadeDelegate

extension BumpUpFreeViewModel: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
        let trackerEvent = TrackerEvent.listingShare(listing, network: shareType.trackingShareNetwork,
                                                     buttonPosition: .bumpUp, typePage: .listingDetail,
                                                     isBumpedUp: EventParameterBoolean.falseParameter)
        tracker.trackEvent(trackerEvent)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShowAutoFadingMessage(message) { [weak self] in
                switch state {
                case .completed:
                    self?.close(withCompletion: {
                        self?.bumpUpProduct(withNetwork: shareType.trackingShareNetwork)
                    })
                case .cancelled, .failed:
                    break
                }
            }
        }

        let event: TrackerEvent?
        switch state {
        case .completed:
            event = TrackerEvent.listingShareComplete(listing, network: shareType.trackingShareNetwork,
                                                      typePage: .listingDetail)
        case .failed:
            event = nil
        case .cancelled:
            event = TrackerEvent.listingShareCancel(listing, network: shareType.trackingShareNetwork,
                                                    typePage: .listingDetail)
        }
        if let event = event {
            tracker.trackEvent(event)
        }
    }

    private func messageForShareIn(_ shareType: ShareType, finishedWithState state: SocialShareState) -> String? {
        switch (shareType, state) {
        case (.email, .failed):
            return R.Strings.productShareEmailError
        case (.facebook, .failed):
            return R.Strings.sellSendErrorSharingFacebook
        case (.fbMessenger, .failed):
            return R.Strings.sellSendErrorSharingFacebook
        case (.sms, .completed):
            return R.Strings.productShareSmsOk
        case (.sms, .failed):
            return R.Strings.productShareSmsError
        case (.copyLink, .completed):
            return R.Strings.productShareCopylinkOk
        case (_, .completed):
            return R.Strings.productShareGenericOk
        default:
            break
        }
        return nil
    }
}


// MARK: Bump Up Methods

extension BumpUpFreeViewModel {
    func bumpUpProduct(withNetwork shareNetwork: EventParameterShareNetwork) {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump FREE")
        guard let listingId = listing.objectId, let letgoItemId = self.letgoItemId else { return }
        purchasesShopper?.requestFreeBumpUp(forListingId: listingId, letgoItemId: letgoItemId,
                                                      shareNetwork: shareNetwork)
    }
}
