//
//  FreePostingMode+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

extension FreePostingMode {
    
    var enabled: Bool {
        switch self {
        case .Disabled:
            return false
        case .SplitButton, .OneButton:
            return true
        }
    }
    
    func getEventParameterFreePostingComplete(price: ProductPrice) -> EventParameterFreePosting {
        switch self {
        case .Disabled:
            return .Unset
        case .OneButton, .SplitButton:
            return price.free ? .True : .False
        }
    }
}
