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

extension NSDate: Decodable {

    private static let millisecondsThreshold: Int64 = 20000000000  //Year 2603 seems big enough 🍾

    public static func decode(j: JSON) -> Decoded<NSDate> {
        switch j {
        case .Number(let number):
            let seconds = number.longLongValue > NSDate.millisecondsThreshold ? number.longLongValue/Int64(1000) :
                                                                                number.longLongValue
            return Decoded<NSDate>.fromOptional(NSDate(timeIntervalSince1970: Double(seconds)))
        case .String(let string):
            return Decoded<NSDate>.fromOptional(InternalCore.dateFormatter.dateFromString(string))
        default:
            return .Failure(.TypeMismatch(expected: "Number or String ISO format", actual: j.description))
        }
    }
}

public extension JSON {
    public static func parse(data data: NSData) -> JSON? {
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            return JSON(object)
        } catch  {
            return nil
        }
    }
}

public extension NSJSONSerialization {

    public static func fromData(data: NSData) -> AnyObject? {
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            return object
        } catch  {
            return nil
        }
    }
}
