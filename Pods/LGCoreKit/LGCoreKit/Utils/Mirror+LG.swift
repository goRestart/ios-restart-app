//
//  Mirror+LG.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 14/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation


extension Mirror {

    /**
    Creates a dictionary with all the properties of an object like [PropertyName(String): Value(AnyObject)]

    - returns: The object transformed into a dictionary
    */
    func toDictionary() -> [String: AnyObject] {
        var dict = [String: AnyObject]()

        for attr in self.children {
            if let propertyName = attr.label {
                dict[propertyName] = attr.value as? AnyObject
            }
        }

        // Add properties of superclass:
        if let parent = self.superclassMirror() {
            for (propertyName, value) in parent.toDictionary() {
                dict[propertyName] = value
            }
        }

        return dict
    }
}
