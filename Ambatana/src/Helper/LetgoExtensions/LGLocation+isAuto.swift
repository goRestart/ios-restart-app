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
    public var isAuto: Bool {
        guard let locationType = type else { return false }
        switch locationType {
        case .Manual:
            return false
        case .Sensor, .IPLookup, .Regional:
            return true
        }
    }
}
