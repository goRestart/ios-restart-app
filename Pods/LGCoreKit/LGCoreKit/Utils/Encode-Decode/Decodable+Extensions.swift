//
//  Decodable+Extensions.swift
//  LGCoreKit
//
//  Created by Nestor on 23/10/2017.
//  Copyright © 2017 Nestor. All rights reserved.
//

import Foundation

public extension Decodable {
    static func decode(jsonData: Data) throws -> Self {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Self.self, from: jsonData)
        } catch {
            logMessage(.debug, type: .parsing, message: "\(Self.self) \(error)")
            if ProcessInfo.processInfo.environment["isRunningUnitTests"] != nil {
                print("⚠️ Decodable ⚠️ ---> \(Self.self) \(error)")
            }
            throw error
        }
    }
}
