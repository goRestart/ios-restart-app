//
//  StandardTypesExtensions.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 29/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

extension LGSize : Decodable {

    /**
    Expects a json in the form:

    {
        "width": 1920,
        "height": 1080,
    }
    */
    public static func decode(j: JSON) -> Decoded<LGSize> {
        return curry(LGSize.init)
            <^> j <| "width"
            <*> j <| "height"
    }
}

public extension JSON {
    public static func parse(data data: NSData) -> JSON? {
        do {
            let object: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            return JSON.parse(object)
        } catch  {
            return nil
        }
    }
}

public extension NSJSONSerialization {

    public static func fromData(data: NSData) -> AnyObject? {
        do {
            let object: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            return object
        } catch  {
            return nil
        }
    }
}
