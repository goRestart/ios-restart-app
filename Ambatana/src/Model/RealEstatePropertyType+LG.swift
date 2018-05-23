import Foundation
import LGCoreKit
import LGComponents

extension RealEstatePropertyType {
    var localizedString: String {
        switch self {
        case .apartment:
            return R.Strings.realEstateTypePropertyApartment
        case .room:
            return R.Strings.realEstateTypePropertyRoom
        case .house:
            return R.Strings.realEstateTypePropertyHouse
        case .other:
            return R.Strings.realEstateTypePropertyOthers
        case .commercial:
            return R.Strings.realEstateTypePropertyCommercial
        case .flat:
            return R.Strings.realEstateTypePropertyFlat
        case .land:
            return R.Strings.realEstateTypePropertyLand
        case .villa:
            return R.Strings.realEstateTypePropertyVilla
        }
    }
    
    var shortLocalizedString: String {
        switch self {
        case .apartment:
            return R.Strings.realEstateTitleGeneratorPropertyTypeApartment
        case .room:
            return R.Strings.realEstateTitleGeneratorPropertyTypeRoom
        case .house:
            return R.Strings.realEstateTitleGeneratorPropertyTypeHouse
        case .other:
            return R.Strings.realEstateTitleGeneratorPropertyTypeOther
        case .commercial:
            return R.Strings.realEstateTitleGeneratorPropertyTypeCommercial
        case .flat:
            return R.Strings.realEstateTypePropertyFlat
        case .land:
            return R.Strings.realEstateTypePropertyLand
        case .villa:
            return R.Strings.realEstateTypePropertyVilla
        }
    }
    
    static func allValues(postingFlowType: PostingFlowType) -> [RealEstatePropertyType] {
        return postingFlowType == .turkish ? [.flat, .villa, .commercial, .land, .other] : [.apartment, .room, .house, .commercial, .other]
    }
    
    func position(postingFlowType: PostingFlowType) -> Int? {
        return RealEstatePropertyType.allValues(postingFlowType: postingFlowType).index(of: self)
    }
}
