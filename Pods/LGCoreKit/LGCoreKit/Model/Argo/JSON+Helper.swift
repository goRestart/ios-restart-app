//
//  JSON+Helper.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 12/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo

// MARK: - Basic types

public extension JSON {
    func decode(_ key: Swift.String) -> JSON? {
        let decoded: Decoded<JSON> = self <| key
        return decoded.value
    }
    func decode(_ key: Swift.String) -> Swift.Bool? {
        let decoded: Decoded<Swift.Bool> = self <| key
        return decoded.value
    }
    func decode(_ key: Swift.String) -> Int? {
        let decoded: Decoded<Int> = self <| key
        return decoded.value
    }
    func decode(_ key: Swift.String) -> [Int]? {
        let decoded: Decoded<[Int]> = self <|| key
        return decoded.value
    }
    func decode(_ key: Swift.String) -> Double? {
        let decoded: Decoded<Double> = self <| key
        return decoded.value
    }
    func decode(_ key: Swift.String) -> Swift.String? {
        let decoded: Decoded<Swift.String> = self <| key
        return decoded.value
    }
    func decode(_ keys: [Swift.String]) -> Swift.String? {
        let decoded: Decoded<Swift.String> = self <| keys
        return decoded.value
    }
}


// MARK: - Filtered array (will return an array of all elements that are success)

extension Collection where Iterator.Element: Decodable, Iterator.Element == Iterator.Element.DecodedType {
    /**
     Decode `JSON` into an array of values where the elements of the array are
     `Decodable`.

     If the `JSON` is an array of `JSON` objects, this returns a decoded array
     of values by mapping the element's `decode` function over the `JSON` and
     then applying `sequence` to the result. This makes this `decode` function
     an all-or-nothing operation (See the documentation for `sequence` for more
     info).

     If the `JSON` is not an array, this returns a type mismatch.

     - parameter j: The `JSON` value to decode

     - returns: A decoded array of values
     */
    static func filteredDecode(_ j: JSON) -> Decoded<[Generator.Element]> {
        switch j {
        case let .array(a): return filteredSequence(a.map(Generator.Element.decode))
        default: return .typeMismatch(expected: "array", actual: j)
        }
    }
}

func filteredSequence<T>(_ xs: [Decoded<T>]) -> Decoded<[T]> {
    var accum: [T] = []
    accum.reserveCapacity(xs.count)

    for x in xs {
        switch x {
        case let .success(value): accum.append(value)
        case .failure: continue
        }
    }
    return pure(accum)
}
