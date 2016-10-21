//
//  ProductPrice.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 07/10/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum ProductPrice {
    case Free
    case Normal(Double)
    case Negotiable(Double)
    case FirmPrice(Double)

    public var value: Double {
        switch self {
        case .Free:
            return 0
        case let .Normal(price):
            return price
        case let .Negotiable(price):
            return price
        case let .FirmPrice(price):
            return price
        }
    }

    public var free: Bool {
        switch self {
        case .Free:
            return true
        case .Negotiable, .FirmPrice, .Normal:
            return false
        }
    }

    var priceFlag: ProductPriceFlag {
        switch self {
        case .Free:
            return .Free
        case .Normal:
            return .Normal
        case .Negotiable:
            return .Negotiable
        case .FirmPrice:
            return .FirmPrice
        }
    }

    static func fromPrice(price: Double?, andFlag flag: ProductPriceFlag?) -> ProductPrice {
        let price = price ?? 0
        guard let flag = flag else { return .Normal(price) }
        switch flag {
        case .Free:
            return .Free
        case .Normal:
            return .Normal(price)
        case .Negotiable:
            return .Negotiable(price)
        case .FirmPrice:
            return .FirmPrice(price)
        }
    }
}

enum ProductPriceFlag: Int {
    case Normal = 0, Free = 1, Negotiable = 2, FirmPrice = 3
}
