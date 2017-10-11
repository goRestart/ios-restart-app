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
    
    var value: String {
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
            return LGLocalizedString.realEstateBathrooms25
        case .three:
            return LGLocalizedString.realEstateBathrooms3
        case .threeAndHalf:
            return LGLocalizedString.realEstateBathrooms35
        case .four:
            return LGLocalizedString.realEstateBathrooms4
        }
    }
    
    static var allValues: [NumberOfBathrooms] {
        return [.zero, .one, .oneAndHalf, .two, .twoAndHalf, .three, .threeAndHalf, .four]
    }
}
