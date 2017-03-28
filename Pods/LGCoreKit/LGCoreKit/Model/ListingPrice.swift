//
//  ListingPrice.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 07/10/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public func ==(lhs: ListingPrice, rhs: ListingPrice) -> Bool {
    switch (lhs, rhs) {
    case (.free, .free): return true
    case (.normal(let a), .normal(let b)) where a == b: return true
    case (.negotiable(let a), .negotiable(let b)) where a == b: return true
    case (.firmPrice(let a), .firmPrice(let b)) where a == b: return true
    default: return false
    }
}

public enum ListingPrice: Equatable {
    case free
    case normal(Double)
    case negotiable(Double)
    case firmPrice(Double)

    public var value: Double {
        switch self {
        case .free:
            return 0
        case let .normal(price):
            return price
        case let .negotiable(price):
            return price
        case let .firmPrice(price):
            return price
        }
    }

    public var free: Bool {
        switch self {
        case .free:
            return true
        case .negotiable, .firmPrice, .normal:
            return false
        }
    }

    var priceFlag: ListingPriceFlag {
        switch self {
        case .free:
            return .free
        case .normal:
            return .normal
        case .negotiable:
            return .negotiable
        case .firmPrice:
            return .firmPrice
        }
    }

    static func fromPrice(_ price: Double?, andFlag flag: ListingPriceFlag?) -> ListingPrice {
        let price = price ?? 0
        guard let flag = flag else { return .normal(price) }
        switch flag {
        case .free:
            return .free
        case .normal:
            return .normal(price)
        case .negotiable:
            return .negotiable(price)
        case .firmPrice:
            return .firmPrice(price)
        }
    }
}

enum ListingPriceFlag: Int {
    case normal = 0
    case free = 1
    case negotiable = 2
    case firmPrice = 3
}
