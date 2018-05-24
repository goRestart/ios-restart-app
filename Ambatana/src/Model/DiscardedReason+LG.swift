import LGCoreKit
import LGComponents

extension DiscardedReason {
    
    var message: String {
        let reason: String
        switch self {
        case .badManners: reason = R.Strings.discardedProductsReasonGoodManners
        case .duplicated: reason = R.Strings.discardedProductsReasonDuplicated
        case .nonRealisticPrice: reason = R.Strings.discardedProductsReasonNonRealisticPrice
        case .poorAdQuality: reason = R.Strings.discardedProductsReasonPoorAdQuality
        case .photoUnclear: reason = R.Strings.discardedProductsReasonPhotoNotClear
        case .referenceToCompetitors: reason = R.Strings.discardedProductsReasonReferenceToCompetitors
        case .stockPhotoOnly: reason = R.Strings.discardedProductsReasonStockPhotoOnly
        default: reason = ""
        }
        return reason
    }
}
