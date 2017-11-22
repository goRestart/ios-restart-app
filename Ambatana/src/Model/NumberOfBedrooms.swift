//
//  NumberOfBedrooms.swift
//  LetGo
//
//  Created by Juan Iglesias on 11/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

enum NumberOfBedrooms: Int {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    
    var localizedString: String {
        switch self {
        case .zero:
            return LGLocalizedString.realEstateBedrooms0
        case .one:
            return LGLocalizedString.realEstateBedrooms1
        case .two:
            return LGLocalizedString.realEstateBedrooms2
        case .three:
            return LGLocalizedString.realEstateBedrooms3
        case .four:
            return LGLocalizedString.realEstateBedrooms4
        }
    }

    var shortLocalizedString: String {
        switch self {
        case .zero:
            return LGLocalizedString.realEstateTitleGeneratorBedroomsStudio
        case .one:
            return LGLocalizedString.realEstateTitleGeneratorBedroomsOne
        case .two:
            return LGLocalizedString.realEstateTitleGeneratorBedroomsTwo
        case .three:
            return LGLocalizedString.realEstateTitleGeneratorBedroomsThree
        case .four:
            return LGLocalizedString.realEstateTitleGeneratorBedroomsFour
        }
    }
    
    var summaryLocalizedString: String {
        switch self {
        case .zero:
            return LGLocalizedString.realEstateBedrooms0
        case .one:
            return LGLocalizedString.realEstateBedrooms1 + " " + LGLocalizedString.realEstateSummaryBedroomTitle
        case .two:
            return LGLocalizedString.realEstateBedrooms2 + " " + LGLocalizedString.realEstateSummaryBedroomsTitle
        case .three:
            return LGLocalizedString.realEstateBedrooms3 + " " + LGLocalizedString.realEstateSummaryBedroomsTitle
        case .four:
            return LGLocalizedString.realEstateBedrooms4 + " " + LGLocalizedString.realEstateSummaryBedroomsTitle
        }
    }
    
    var position: Int {
        switch self {
        case .zero:
            return 0
        case .one:
            return 1
        case .two:
            return 2
        case .three:
            return 3
        case .four:
            return 4
        }
    }
    
    static var allValues: [NumberOfBedrooms] {
        return [.zero, .one, .two, .three, .four]
    }
}
