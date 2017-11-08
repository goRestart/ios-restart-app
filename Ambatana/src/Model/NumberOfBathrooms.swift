//
//  NumberOfBathrooms.swift
//  LetGo
//
//  Created by Juan Iglesias on 11/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

enum NumberOfBathrooms: Float {
    case zero = 0.0
    case one = 1.0
    case two = 2.0
    case three = 3.0
    case four = 4.0
    
    var localizedString: String {
        switch self {
        case .zero:
            return LGLocalizedString.realEstateBathrooms0
        case .one:
            return LGLocalizedString.realEstateBathrooms1
        case .two:
            return LGLocalizedString.realEstateBathrooms2
        case .three:
            return LGLocalizedString.realEstateBathrooms3
        case .four:
            return LGLocalizedString.realEstateBathrooms4
        }
    }
    
    var summaryLocalizedString: String {
        switch self {
        case .zero:
            return LGLocalizedString.realEstateBathrooms0
        case .one:
            return LGLocalizedString.realEstateBathrooms1 + " " + LGLocalizedString.realEstateSummaryBathroomTitle
        case .two:
            return LGLocalizedString.realEstateBathrooms2 + " " + LGLocalizedString.realEstateSummaryBathroomsTitle
        case .three:
            return LGLocalizedString.realEstateBathrooms3 + " " + LGLocalizedString.realEstateSummaryBathroomsTitle
        case .four:
            return LGLocalizedString.realEstateBathrooms4 + " " + LGLocalizedString.realEstateSummaryBathroomsTitle
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
    
    static var allValues: [NumberOfBathrooms] {
        return [.zero, .one, .two, .three, .four]
    }
}
