//
//  File.swift
//  LGAnalytics
//
//  Created by Albert Hernández López on 29/03/2018.
//

public enum FilterPriceRange {
    case freePrice
    case priceRange(min: Int?, max: Int?)

    var min: Int? {
        switch self {
        case .freePrice:
            return nil
        case let .priceRange(min: minPrice, max: _):
            return minPrice
        }
    }

    var max: Int? {
        switch self {
        case .freePrice:
            return nil
        case let .priceRange(min: _, max: maxPrice):
            return maxPrice
        }
    }

    var free: Bool {
        switch self {
        case .freePrice:
            return true
        case .priceRange:
            return false
        }
    }
}
