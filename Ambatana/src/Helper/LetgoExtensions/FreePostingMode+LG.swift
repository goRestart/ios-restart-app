//
//  FreePostingMode+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension FreePostingMode {
    
    var enabled: Bool {
        switch self {
        case .Disabled:
            return false
        case .SplitButton, .OneButton:
            return true
        }
    }
}
