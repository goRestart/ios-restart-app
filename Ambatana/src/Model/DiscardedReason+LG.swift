import LGCoreKit

extension DiscardedReason {
    
    var message: String {
        let reason: String
        switch self {
        case .badManners: reason = LGLocalizedString.discardedProductsReasonGoodManners
        case .duplicated: reason = LGLocalizedString.discardedProductsReasonDuplicated
        case .nonRealisticPrice: reason = LGLocalizedString.discardedProductsReasonNonRealisticPrice
        case .poorAdQuality: reason = LGLocalizedString.discardedProductsReasonPoorAdQuality
        case .photoUnclear: reason = LGLocalizedString.discardedProductsReasonPhotoNotClear
        case .referenceToCompetitors: reason = LGLocalizedString.discardedProductsReasonReferenceToCompetitors
        case .stockPhotoOnly: reason = LGLocalizedString.discardedProductsReasonStockPhotoOnly
        default: reason = ""
        }
        return reason
    }
}
