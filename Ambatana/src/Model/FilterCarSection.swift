//
//  FilterCarSection.swift
//  LetGo
//
//  Created by Tomas Cobo on 11/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//
import LGCoreKit

enum FilterCarSection {
    case firstSection, secondSection, make, model, year
    
    static var all: [FilterCarSection] {
        return [.firstSection, .secondSection, .make, .model, .year]
    }
    
    var isCarSellerTypeSection: Bool {
        return self == .firstSection || self == .secondSection
    }
    
    var isFirstSection: Bool {
        return self == .firstSection
    }
    
    func title(feature: FilterSearchCarSellerType) -> String {
        switch self {
        case .firstSection:
            return feature.firstSectionTitle
        case .secondSection:
            return feature.secondSectionTitle
        case .make:
            return LGLocalizedString.postCategoryDetailCarMake
        case .model:
            return LGLocalizedString.postCategoryDetailCarModel
        case .year:
            return ""
        }
    }
}

extension FilterCarSection {
    var carSellerType: CarSellerType {
        guard case .firstSection = self else { return .professional }
        return .individual
    }
}

private extension FilterSearchCarSellerType {
    var firstSectionTitle: String {
        switch self {
        case .control, .baseline:
            return ""
        case .variantA:
            return LGLocalizedString.filtersCarSellerTypePrivate
        case .variantB:
            return LGLocalizedString.filtersCarSellerTypeInvidual
        case .variantC, .variantD:
            return LGLocalizedString.filtersCarSellerTypeAll
        }
    }
    
    var secondSectionTitle: String {
        switch self {
        case .control, .baseline:
            return ""
        case .variantA, .variantC:
            return LGLocalizedString.filtersCarSellerTypeProfessional
        case .variantB, .variantD:
            return LGLocalizedString.filtersCarSellerTypeDealership
        }
    }
}
