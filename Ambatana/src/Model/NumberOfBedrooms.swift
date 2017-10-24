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
    
    static var allValues: [NumberOfBedrooms] {
        return [.zero, .one, .two, .three, .four]
    }
}
