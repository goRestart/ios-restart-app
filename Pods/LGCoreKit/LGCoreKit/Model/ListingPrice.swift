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
    default: return false
    }
}

public enum ListingPrice: Equatable {
    case normal(Double)
    case free

    public var value: Double {
        switch self {
        case .free:
            return 0
        case let .normal(price):
            return price
        }
    }

    public var isFree: Bool {
        return self == .free
    }

    var priceFlag: ListingPriceFlag {
        switch self {
        case .free:
            return .free
        case .normal:
            return .negotiable
        }
    }

    static func fromPrice(_ price: Double?, andFlag flag: ListingPriceFlag?) -> ListingPrice {
        let price = price ?? 0
        guard let flag = flag else { return .normal(price) }
        switch flag {
        case .free:
            return .free
        case .normal, .negotiable, .firmPrice:
            return .normal(price)
        }
    }
}

struct ListingPriceDecodable: Decodable {
    let amount: Double
    let currency: String
    let flag: ListingPriceFlag
}

/// Maps the backend price flag
///
/// - normal: [DEPRECATED]
/// - free: The listing is offered as free
/// - negotiable: The listing has a price (that could also be 0)
/// - firmPrice: [DEPRECATED]
enum ListingPriceFlag: Int, Decodable {
    case normal = 0
    case free = 1
    case negotiable = 2
    case firmPrice = 3
}
