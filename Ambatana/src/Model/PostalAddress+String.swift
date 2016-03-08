//
//  PostalAddress+String.swift
//  LetGo
//
//  Created by Albert Hernández López on 04/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

extension PostalAddress {
    var string: String? {
        var components = [String]()
        if let city = city where !city.isEmpty {
            components.append(city)
        }
        if let zipCode = zipCode where !zipCode.isEmpty {
            components.append(zipCode)
        }
        return components.isEmpty ? nil : components.joinWithSeparator(", ")
    }
}
