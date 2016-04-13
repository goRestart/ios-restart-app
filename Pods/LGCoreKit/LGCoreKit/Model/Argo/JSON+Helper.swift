//
//  JSON+Helper.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 12/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo

extension JSON {
    func decode(key: Swift.String) -> JSON? {
        let decoded: Decoded<JSON> = self <| key
        return decoded.value
    }
    func decode(key: Swift.String) -> Swift.Bool? {
        let decoded: Decoded<Swift.Bool> = self <| key
        return decoded.value
    }
    func decode(key: Swift.String) -> Int? {
        let decoded: Decoded<Int> = self <| key
        return decoded.value
    }
    func decode(key: Swift.String) -> [Int]? {
        let decoded: Decoded<[Int]> = self <|| key
        return decoded.value
    }
    func decode(key: Swift.String) -> Double? {
        let decoded: Decoded<Double> = self <| key
        return decoded.value
    }
    func decode(key: Swift.String) -> Swift.String? {
        let decoded: Decoded<Swift.String> = self <| key
        return decoded.value
    }
    func decode(keys: [Swift.String]) -> Swift.String? {
        let decoded: Decoded<Swift.String> = self <| keys
        return decoded.value
    }
}
