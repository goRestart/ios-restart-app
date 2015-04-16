//
//  LetGoGoogleAddressComponent.swift
//  LetGo
//
//  Created by Nacho on 15/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class LetGoGoogleAddressComponent: NSObject {
    // data
    var types: [String] = []
    var longName: String!
    var shortName: String!
    
    init(shortName: String, longName: String, types: [String]) {
        self.shortName = shortName
        self.longName = longName
        self.types = types
    }
    
    init?(valuesFromDictionary dictionary: [String: AnyObject]) {
        super.init()
        if let shortName = dictionary[kLetGoRestAPIParameterShortName] as? String { self.shortName = shortName } else { return nil }
        if let longName = dictionary[kLetGoRestAPIParameterShortName] as? String { self.longName = longName } else { return nil }
        if let typesArray = dictionary[kLetGoRestAPIParameterTypes] as? [String] {
            for type in typesArray { self.types.append(type) }
        }
    }
}
