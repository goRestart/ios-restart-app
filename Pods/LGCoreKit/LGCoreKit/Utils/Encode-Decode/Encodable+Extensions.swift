//
//  Encodable+Extensions.swift
//  LGCoreKit
//
//  Created by Nestor on 23/10/2017.
//  Copyright © 2017 Nestor. All rights reserved.
//

import Foundation

public extension Encodable {
    func encodeJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            return try encoder.encode(self)
        } catch {
            logMessage(.debug, type: .parsing, message: "\(Self.self) \(error)")
            #if DEBUG
                print("\(Self.self) \(error)")
            #endif
            throw error
        }
    }
}
