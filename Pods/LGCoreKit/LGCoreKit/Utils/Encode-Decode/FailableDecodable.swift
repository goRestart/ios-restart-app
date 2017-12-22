//
//  FailableDecodable.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 02/11/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

public struct FailableDecodable<Base: Decodable> : Decodable {
    let base: Base?
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

public struct FailableDecodableArray<Element: Decodable> : Decodable {
    var validElements: [Element]
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        while !container.isAtEnd {
            if let element = try container.decode(FailableDecodable<Element>.self).base {
                elements.append(element)
            }
        }
        validElements = elements
    }
}
