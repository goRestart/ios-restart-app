import Foundation
import LGCoreKit
import LGComponents

class BumpUpPayViewModel: BaseViewModel {

    var isBoost: Bool = false
    var listing: Listing
    let maxCountdown: TimeInterval
    private let letgoItemId: String?
    private let storeProductId: String?
    private let typePage: EventParameterTypePage?


    var price: String {
        return purchaseableProduct.formattedCurrencyPrice
    }
    private let purchaseableProduct: PurchaseableProduct
    private let purchasesShopper: PurchasesShopper
    private let tracker: Tracker

    var navigator: BumpUpNavigator?


    // MARK: - Lifecycle

    convenience init(listing: Listing,
                     purchaseableProduct: PurchaseableProduct,
                     letgoItemId: String?,
                     storeProductId: String?,
                     typePage: EventParameterTypePage?,
                     maxCountdown: TimeInterval) {
        let purchasesShopper = LGPurchasesShopper.sharedInstance
        self.init(listing: listing, purchaseableProduct: purchaseableProduct,
                  purchasesShopper: purchasesShopper, letgoItemId: letgoItemId,
                  storeProductId: storeProductId, typePage: typePage, maxCountdown: maxCountdown,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(listing: Listing,
         purchaseableProduct: PurchaseableProduct,
         purchasesShopper: PurchasesShopper,
         letgoItemId: String?,
         storeProductId: String?,
         typePage: EventParameterTypePage?,
         maxCountdown: TimeInterval,
         tracker: Tracker) {
        self.listing = listing
        self.purchaseableProduct = purchaseableProduct
        self.purchasesShopper = purchasesShopper
        self.tracker = tracker
        self.letgoItemId = letgoItemId
        self.storeProductId = storeProductId
        self.typePage = typePage
        self.maxCountdown = maxCountdown
    }

    func viewDidAppear() {
        let trackerEvent = TrackerEvent.bumpBannerInfoShown(type: EventParameterBumpUpType.paid,
                                                            listingId: listing.objectId,
                                                            storeProductId: storeProductId,
                                                            typePage: typePage,
                                                            isBoost: EventParameterBoolean(bool: isBoost))
        tracker.trackEvent(trackerEvent)
    }

    
    // MARK: - Public methods

    func bumpUpPressed() {
        navigator?.bumpUpDidFinish(completion: { [weak self] in
            self?.bumpUpProduct()
        })
    }

    func boostPressed() {
        navigator?.bumpUpDidFinish(completion: { [weak self] in
            self?.boostProduct()
        })
    }

    func closeActionPressed() {
        navigator?.bumpUpDidCancel()
    }

    func timerReachedZero() {
        navigator?.bumpUpDidCancel()
    }


    // MARK: - Private methods

    private func bumpUpProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump with purchase: \(purchaseableProduct)")
        guard let listingId = listing.objectId, let letgoItemId = letgoItemId else { return }
        purchasesShopper.requestPayment(forListingId: listingId,
                                        appstoreProduct: purchaseableProduct,
                                        letgoItemId: letgoItemId,
                                        isBoost: false,
                                        maxCountdown: maxCountdown,
                                        typePage: typePage)
    }

    private func boostProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Boost with purchase: \(purchaseableProduct)")
        guard let listingId = listing.objectId, let letgoItemId = letgoItemId else { return }
        purchasesShopper.requestPayment(forListingId: listingId,
                                        appstoreProduct: purchaseableProduct,
                                        letgoItemId: letgoItemId,
                                        isBoost: true,
                                        maxCountdown: maxCountdown,
                                        typePage: typePage)
    }
}
