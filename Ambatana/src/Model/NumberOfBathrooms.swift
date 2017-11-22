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
    case oneAndHalf = 1.5
    case two = 2.0
    case twoAndHalf = 2.5
    case three = 3.0
    case threeAndHalf = 3.5
    case four = 4.0
    
    var localizedString: String {
        switch self {
        case .zero:
            return LGLocalizedString.realEstateBathrooms0
        case .one:
            return LGLocalizedString.realEstateBathrooms1
        case .oneAndHalf:
            return LGLocalizedString.realEstateBathrooms15
        case .two:
            return LGLocalizedString.realEstateBathrooms2
        case .twoAndHalf:
            return LGLocalizedString.realEstateBathrooms15
        case .three:
            return LGLocalizedString.realEstateBathrooms3
        case .threeAndHalf:
            return LGLocalizedString.realEstateBathrooms15
        case .four:
            return LGLocalizedString.realEstateBathrooms4
        }
    }
    
    var shortLocalizedString: String {
        switch self {
        case .zero:
            return LGLocalizedString.realEstateTitleGeneratorBathrooms0
        case .one:
            return LGLocalizedString.realEstateTitleGeneratorBathrooms1
        case .two:
            return LGLocalizedString.realEstateTitleGeneratorBathrooms2
        case .three:
            return LGLocalizedString.realEstateTitleGeneratorBathrooms3
        case .four:
            return LGLocalizedString.realEstateTitleGeneratorBathrooms4
        }
    }
    
    var summaryLocalizedString: String {
        switch self {
        case .zero:
            return LGLocalizedString.realEstateBathrooms0
        case .one:
            return LGLocalizedString.realEstateBathrooms1 + " " + LGLocalizedString.realEstateSummaryBathroomTitle
        case .oneAndHalf:
            return LGLocalizedString.realEstateBathrooms15 + " " + LGLocalizedString.realEstateSummaryBathroomTitle
        case .two:
            return LGLocalizedString.realEstateBathrooms2 + " " + LGLocalizedString.realEstateSummaryBathroomsTitle
        case .twoAndHalf:
            return LGLocalizedString.realEstateBathrooms25 + " " + LGLocalizedString.realEstateSummaryBathroomTitle
        case .three:
            return LGLocalizedString.realEstateBathrooms3 + " " + LGLocalizedString.realEstateSummaryBathroomsTitle
        case .threeAndHalf:
            return LGLocalizedString.realEstateBathrooms35 + " " + LGLocalizedString.realEstateSummaryBathroomTitle
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
        case .oneAndHalf:
            return 2
        case .two:
            return 3
        case .twoAndHalf:
            return 4
        case .three:
            return 5
        case .threeAndHalf:
            return 6
        case .four:
            return 7
        }
    }
    
    static var allValues: [NumberOfBathrooms] {
        return [.zero, .one, .oneAndHalf, .two, .twoAndHalf, .three, .threeAndHalf, .four]
    }
}
