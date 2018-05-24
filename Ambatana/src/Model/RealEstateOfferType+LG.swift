import Foundation
import LGCoreKit
import LGComponents

extension RealEstateOfferType {
    var localizedString: String {
        switch self {
        case .rent:
            return R.Strings.realEstateOfferTypeRent
        case .sale:
            return R.Strings.realEstateOfferTypeSale
        }
    }
    
    var shortLocalizedString: String {
        switch self {
        case .rent:
            return R.Strings.realEstateTitleGeneratorOfferTypeRent
        case .sale:
            return R.Strings.realEstateTitleGeneratorOfferTypeSale
        }
    }
    
    static var allValues: [RealEstateOfferType] {
        return [.rent, .sale]
    }
    
    var position: Int {
        switch self {
        case .rent:
            return 0
        case .sale:
            return 1
        }
    }
}

