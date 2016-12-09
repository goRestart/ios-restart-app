//
//  Carrier+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 07/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import CoreTelephony

protocol TelephonyNetworkConfigurable {
    func isTurkishCarrier() -> Bool
}

class TelephonyNetworkConfig: TelephonyNetworkConfigurable  {
    
    init() {}
    
    func isTurkishCarrier() -> Bool {
        let turkishISOCountryName = "tr"
        return CTTelephonyNetworkInfo().subscriberCellularProvider?.isoCountryCode == turkishISOCountryName
    }
}
