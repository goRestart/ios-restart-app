//
//  BumperFlag.swift
//  Pods
//
//  Created by Eli Kohen on 22/09/16.
//
//

import Foundation

public protocol BumperFeature {
    static var key: String { get }
    static var values: [String] { get }
    static var defaultValue: String { get }
    static var description: String { get }
}

public extension BumperFeature {
    static var key: String {
        return String(Self)
    }
}
