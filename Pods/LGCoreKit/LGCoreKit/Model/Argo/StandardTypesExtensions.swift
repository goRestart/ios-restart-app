//
//  StandardTypesExtensions.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 29/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

extension LGSize: Decodable {

    /**
    Expects a json in the form:

    {
        "width": 1920,
        "height": 1080,
    }
    */
    public static func decode(_ j: JSON) -> Decoded<LGSize> {
        let result1 = curry(LGSize.init)
        let result2 = result1 <^> j <| "width"
        let result  = result2 <*> j <| "height"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGSize parse error: \(error)")
        }
        return result
    }
}

extension Date: Decodable {

    private static let millisecondsThreshold: Int64 = 20000000000  //Year 2603 seems big enough 🍾

    public static func decode(_ j: JSON) -> Decoded<Date> {
        switch j {
        case .number(let number):
            let seconds = number.int64Value > Date.millisecondsThreshold ? number.int64Value/Int64(1000) :
                                                                                number.int64Value

            return Decoded<Date>.fromOptional(Date(timeIntervalSince1970: TimeInterval(seconds)))
        case .string(let string):
            return Decoded<Date>.fromOptional(InternalCore.dateFormatter.date(from: string))
        default:
            return .failure(.typeMismatch(expected: "Number or String ISO format", actual: j.description))
        }
    }
}

public extension JSON {
    public static func parse(data: Data) -> JSON? {
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return JSON(object)
        } catch  {
            return nil
        }
    }
}

public extension JSONSerialization {

    public static func fromData(_ data: Data) -> Any? {
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return object
        } catch  {
            return nil
        }
    }
}
