//
//  LGLocation+isAuto.swift
//  LetGo
//
//  Created by Juan Iglesias on 22/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

extension LGLocation {
    var isAuto: Bool {
        switch type {
        case .manual:
            return false
        case .sensor, .ipLookup, .regional:
            return true
        }
    }
}
