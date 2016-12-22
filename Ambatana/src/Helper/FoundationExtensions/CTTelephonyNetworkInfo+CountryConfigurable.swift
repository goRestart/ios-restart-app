//
//  CTTelephonyNetworkInfo+CountryConfigurable.swift
//  LetGo
//
//  Created by Juan Iglesias on 07/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import CoreTelephony

protocol CountryConfigurable {
    var countryCode: String? { get }
}

extension CTTelephonyNetworkInfo: CountryConfigurable {
    var countryCode: String? {
        return subscriberCellularProvider?.isoCountryCode
    }
}


