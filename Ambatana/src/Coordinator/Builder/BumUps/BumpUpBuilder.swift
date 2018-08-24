import Foundation
import LGCoreKit

enum BumpUpPurchaseableData {
    case socialMessage(message: SocialMessage)
    case purchaseableProduct(product: PurchaseableProduct)
}

struct BumpUpProductData {
    let bumpUpPurchaseableData: BumpUpPurchaseableData
    let letgoItemId: String?
    let storeProductId: String?

    var hasPaymentId: Bool {
        return letgoItemId != nil
    }
}

protocol BumpUpAssembly {
    func buildFreeBumpUp(forListing listing: Listing,
                         socialMessage: SocialMessage,
                         letgoItemId: String?,
                         storeProductId: String?,
                         typePage: EventParameterTypePage?,
                         maxCountdown: TimeInterval) -> BumpUpFreeViewController
    func buildPayBumpUp(forListing listing: Listing,
                        purchaseableProduct: PurchaseableProduct,
                        letgoItemId: String?,
                        storeProductId: String?,
                        typePage: EventParameterTypePage?,
                        maxCountdown: TimeInterval) -> BumpUpPayViewController
    func buildBumpUpBoost(forListing listing: Listing,
                          purchaseableProduct: PurchaseableProduct,
                          letgoItemId: String?,
                          storeProductId: String?,
                          typePage: EventParameterTypePage?,
                          timeSinceLastBump: TimeInterval,
                          maxCountdown: TimeInterval) -> BumpUpBoostViewController
}

enum BumpUpBuilder {
    case modal(UIViewController)
    case standard(UINavigationController)
}

extension BumpUpBuilder: BumpUpAssembly {
    func buildFreeBumpUp(forListing listing: Listing,
                         socialMessage: SocialMessage,
                         letgoItemId: String?,
                         storeProductId: String?,
                         typePage: EventParameterTypePage?,
                         maxCountdown: TimeInterval) -> BumpUpFreeViewController {
        let bumpUpVM = BumpUpFreeViewModel(listing: listing,
                                           socialMessage: socialMessage,
                                           letgoItemId: letgoItemId,
                                           storeProductId: storeProductId,
                                           typePage: typePage)
        switch self {
        case .modal(let root):
            bumpUpVM.navigator = BumpUpsModalWireframe(root: root)
        case .standard(let nav):
            bumpUpVM.navigator = BumpUpsStandardWireframe(nc: nav)
        }
        return BumpUpFreeViewController(viewModel: bumpUpVM)
    }

    func buildPayBumpUp(forListing listing: Listing,
                        purchaseableProduct: PurchaseableProduct,
                        letgoItemId: String?,
                        storeProductId: String?,
                        typePage: EventParameterTypePage?,
                        maxCountdown: TimeInterval) -> BumpUpPayViewController {
        let bumpUpVM = BumpUpPayViewModel(listing: listing,
                                          purchaseableProduct: purchaseableProduct,
                                          letgoItemId: letgoItemId,
                                          storeProductId: storeProductId,
                                          typePage: typePage,
                                          maxCountdown: maxCountdown)
        switch self {
        case .modal(let root):
            bumpUpVM.navigator = BumpUpsModalWireframe(root: root)
        case .standard(let nav):
            bumpUpVM.navigator = BumpUpsStandardWireframe(nc: nav)
        }
        return BumpUpPayViewController(viewModel: bumpUpVM)
    }

    func buildBumpUpBoost(forListing listing: Listing,
                          purchaseableProduct: PurchaseableProduct,
                          letgoItemId: String?,
                          storeProductId: String?,
                          typePage: EventParameterTypePage?,
                          timeSinceLastBump: TimeInterval,
                          maxCountdown: TimeInterval) -> BumpUpBoostViewController {
        let bumpUpVM = BumpUpPayViewModel(listing: listing,
                                          purchaseableProduct: purchaseableProduct,
                                          letgoItemId: letgoItemId,
                                          storeProductId: storeProductId,
                                          typePage: typePage,
                                          maxCountdown: maxCountdown)
        bumpUpVM.isBoost = true
        switch self {
        case .modal(let root):
            bumpUpVM.navigator = BumpUpsModalWireframe(root: root)
        case .standard(let nav):
            bumpUpVM.navigator = BumpUpsStandardWireframe(nc: nav)
        }
        return BumpUpBoostViewController(viewModel: bumpUpVM,
                                         featureFlags: FeatureFlags.sharedInstance,
                                         timeSinceLastBump: timeSinceLastBump)
    }
}
