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
        if let zipCode = zipCode, !zipCode.isEmpty {
            components.append(zipCode)
        }
        if let city = city, !city.isEmpty {
            components.append(city)
        }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }

    var cityStateString: String? {
        var components = [String]()
        if let city = city, !city.isEmpty {
            components.append(city)
        }
        if let state = state, !state.isEmpty {
            components.append(state)
        } else if let countryCode = countryCode, !countryCode.isEmpty {
            components.append(countryCode)
        }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}
