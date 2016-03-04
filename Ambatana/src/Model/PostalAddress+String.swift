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
        var address = ""
        if let city = city {
            if !city.isEmpty {
                address += city
            }
        }
        if let zipCode = zipCode {
            if !zipCode.isEmpty {
                if !address.isEmpty {
                    address += ", "
                }
                address += zipCode
            }
        }
        return address.isEmpty ? nil : address
    }
}
