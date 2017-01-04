//
//  NSNullableOptional.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 04/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

/**
Optional that can contain NSNull.
*/
enum Nullable<Wrapped>: Unwrappable {
    case none
    case null
    case some(Wrapped)


    /**
    Creates an instance initialized with the given value.
    - parameter value: The value.
    - returns: `Some` with the given value or `Null`.
    */
    static func value(_ value: Wrapped?) -> Nullable<Wrapped> {
        if let value = value {
            return Nullable<Wrapped>.some(value)
        }
        else {
            return Nullable<Wrapped>.null
        }
    }

    static func literal(_ value: Any) -> Nullable<Wrapped> {
        if let value = value as? Wrapped {
            return Nullable<Wrapped>.some(value)
        } else {
            return Nullable<Wrapped>.none
        }
    }
}


// MARK: - Unwrappable

extension Nullable {
    func unwrap() -> Any? {
        switch self {
        case .some(let value):
            return value
        case .none:
            return nil
        case .null:
            return NSNull()
        }
    }
}


// MARK: - NilLiteralConvertible

extension Nullable: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = Nullable<Wrapped>.none
    }
}


// MARK: - StringLiteralConvertible

extension Nullable: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = Nullable.literal(value)
    }

    init(extendedGraphemeClusterLiteral value: String) {
        self = Nullable.literal(value)
    }

    init(unicodeScalarLiteral value: String) {
        self = Nullable.literal(value)
    }
}


// MARK: - BooleanLiteralConvertible

extension Nullable: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self = Nullable.literal(value)
    }
}


// MARK: - IntegerLiteralConvertible

extension Nullable: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = Nullable.literal(value)
    }
}


// MARK: - FloatLiteralConvertible

extension Nullable: ExpressibleByFloatLiteral {
    init(floatLiteral value: Double) {
        self = Nullable.literal(value)
    }
}


// MARK: - ArrayLiteralConvertible

extension Nullable: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Any...) {
        self = Nullable.literal(elements)
    }
}


// MARK: - DictionaryLiteralConvertible

extension Nullable: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, Any)...) {
        var dict: [String: Any] = [:]
        for element in elements {
            dict[element.0] = element.1
        }
        self = Nullable.literal(dict)
    }
}
