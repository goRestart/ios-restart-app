//
//  PostalAddress+String.swift
//  LetGo
//
//  Created by Albert Hernández López on 04/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

extension PostalAddress {
    var zipCodeCityString: String? {
        var components = [String]()
        if let zipCode = zipCode where !zipCode.isEmpty {
            components.append(zipCode)
        }
        if let city = city where !city.isEmpty {
            components.append(city)
        }
        return components.isEmpty ? nil : components.joinWithSeparator(", ")
    }

    var cityStateString: String? {
        var components = [String]()
        if let city = city where !city.isEmpty {
            components.append(city)
        }
        if let state = state where !state.isEmpty {
            components.append(state)
        } else if let countryCode = countryCode where !countryCode.isEmpty {
            components.append(countryCode)
        }
        return components.isEmpty ? nil : components.joinWithSeparator(", ")
    }
}
