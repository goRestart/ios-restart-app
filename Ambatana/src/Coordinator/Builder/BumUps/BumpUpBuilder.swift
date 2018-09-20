import Foundation
import LGCoreKit

struct BumpUpProductData {
    let purchaseableProduct: PurchaseableProduct
    let letgoItemId: String?
    let storeProductId: String?
    let featurePurchase: FeaturePurchase?

    var hasPaymentId: Bool {
        return letgoItemId != nil
    }
}

extension Array where Element == BumpUpProductData {
    var hasPaymentIds: Bool {
        return !(self.filter({ $0.hasPaymentId }).isEmpty)
    }
}

protocol BumpUpAssembly {
    func buildPayBumpUp(forListing listing: Listing,
                        purchases: [BumpUpProductData],
                        typePage: EventParameterTypePage?,
                        maxCountdown: TimeInterval) -> BumpUpPayViewController
    func buildBumpUpBoost(forListing listing: Listing,
                          purchases: [BumpUpProductData],
                          typePage: EventParameterTypePage?,
                          timeSinceLastBump: TimeInterval,
                          maxCountdown: TimeInterval) -> BumpUpBoostViewController
    func buildMultiDayBumpUp(forListing listing: Listing,
                             purchases: [BumpUpProductData],
                             typePage: EventParameterTypePage?,
                             maxCountdown: TimeInterval) -> BumpUpMultiDayViewController
    func buildMultiDayInfoBumpUp(forListing listing: Listing,
                                 featurePurchaseType: FeaturePurchaseType,
                                 typePage: EventParameterTypePage?,
                                 timeSinceLastBump: TimeInterval,
                                 maxCountdown: TimeInterval) -> BumpUpMultiDayInfoViewController
}

enum BumpUpBuilder {
    case modal(UIViewController)
    case standard(UINavigationController)
}

extension BumpUpBuilder: BumpUpAssembly {
    func buildPayBumpUp(forListing listing: Listing,
                        purchases: [BumpUpProductData],
                        typePage: EventParameterTypePage?,
                        maxCountdown: TimeInterval) -> BumpUpPayViewController {
        let bumpUpVM = BumpUpPayViewModel(listing: listing,
                                          purchases: purchases,
                                          typePage: typePage,
                                          maxCountdown: maxCountdown,
                                          timeSinceLastBump: nil)
        switch self {
        case .modal(let root):
            bumpUpVM.navigator = BumpUpsModalWireframe(root: root)
        case .standard(let nav):
            bumpUpVM.navigator = BumpUpsStandardWireframe(nc: nav)
        }
        return BumpUpPayViewController(viewModel: bumpUpVM)
    }

    func buildBumpUpBoost(forListing listing: Listing,
                          purchases: [BumpUpProductData],
                          typePage: EventParameterTypePage?,
                          timeSinceLastBump: TimeInterval,
                          maxCountdown: TimeInterval) -> BumpUpBoostViewController {
        let bumpUpVM = BumpUpPayViewModel(listing: listing,
                                          purchases: purchases,
                                          typePage: typePage,
                                          maxCountdown: maxCountdown,
                                          timeSinceLastBump: timeSinceLastBump)
        bumpUpVM.isBoost = true
        switch self {
        case .modal(let root):
            bumpUpVM.navigator = BumpUpsModalWireframe(root: root)
        case .standard(let nav):
            bumpUpVM.navigator = BumpUpsStandardWireframe(nc: nav)
        }
        return BumpUpBoostViewController(viewModel: bumpUpVM,
                                         featureFlags: FeatureFlags.sharedInstance)
    }

    func buildMultiDayBumpUp(forListing listing: Listing,
                             purchases: [BumpUpProductData],
                             typePage: EventParameterTypePage?,
                             maxCountdown: TimeInterval) -> BumpUpMultiDayViewController {
        let bumpUpVM = BumpUpPayViewModel(listing: listing,
                                          purchases: purchases,
                                          typePage: typePage,
                                          maxCountdown: maxCountdown,
                                          timeSinceLastBump: nil)
        switch self {
        case .modal(let root):
            bumpUpVM.navigator = BumpUpsModalWireframe(root: root)
        case .standard(let nav):
            bumpUpVM.navigator = BumpUpsStandardWireframe(nc: nav)
        }
        return BumpUpMultiDayViewController(viewModel: bumpUpVM,
                                            featureFlags: FeatureFlags.sharedInstance)
    }

    func buildMultiDayInfoBumpUp(forListing listing: Listing,
                                 featurePurchaseType: FeaturePurchaseType,
                                 typePage: EventParameterTypePage?,
                                 timeSinceLastBump: TimeInterval,
                                 maxCountdown: TimeInterval) -> BumpUpMultiDayInfoViewController {
        let bumpUpVM = BumpUpPayViewModel(listing: listing,
                                          purchases: [],
                                          typePage: typePage,
                                          maxCountdown: maxCountdown,
                                          timeSinceLastBump: timeSinceLastBump)
        switch self {
        case .modal(let root):
            bumpUpVM.navigator = BumpUpsModalWireframe(root: root)
        case .standard(let nav):
            bumpUpVM.navigator = BumpUpsStandardWireframe(nc: nav)
        }
        return BumpUpMultiDayInfoViewController(viewModel: bumpUpVM,
                                                selectedFeaturePurchaseType: featurePurchaseType)
    }
}
