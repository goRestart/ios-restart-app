//
//  Currency.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public struct Currency: Equatable {
    public let code: String
    public let symbol: String
    public init(code: String, symbol: String) {
        self.code = code
        self.symbol = symbol
    }
}

public func ==(lhs: Currency, rhs: Currency) -> Bool {
    return lhs.code == rhs.code && lhs.symbol == rhs.symbol
}

public extension Currency {
    public static func currencyWithCode(_ code: String) -> Currency {
        return InternalCore.currencyHelper.currencyWithCurrencyCode(code)
    }
}

extension Currency: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let currencyCode = try container.decode(String.self)
        self = Currency.currencyWithCode(currencyCode)
    }
}
