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
    case None
    case Null
    case Some(Wrapped)


    /**
    Creates an instance initialized with the given value.
    - parameter value: The value.
    - returns: `Some` with the given value or `Null`.
    */
    static func value(value: Wrapped?) -> Nullable<Wrapped> {
        if let value = value {
            return Nullable<Wrapped>.Some(value)
        }
        else {
            return Nullable<Wrapped>.Null
        }
    }

    static func literal(value: AnyObject) -> Nullable<Wrapped> {
        if let value = value as? Wrapped {
            return Nullable<Wrapped>.Some(value)
        } else {
            return Nullable<Wrapped>.None
        }
    }
}


// MARK: - Unwrappable

extension Nullable {
    func unwrap() -> AnyObject? {
        switch self {
        case .Some(let value):
            return value as? AnyObject
        case .None:
            return nil
        case .Null:
            return NSNull()
        }
    }
}


// MARK: - NilLiteralConvertible

extension Nullable: NilLiteralConvertible {
    init(nilLiteral: ()) {
        self = Nullable<Wrapped>.None
    }
}


// MARK: - StringLiteralConvertible

extension Nullable: StringLiteralConvertible {
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

extension Nullable: BooleanLiteralConvertible {
    init(booleanLiteral value: Bool) {
        self = Nullable.literal(value)
    }
}


// MARK: - IntegerLiteralConvertible

extension Nullable: IntegerLiteralConvertible {
    init(integerLiteral value: Int) {
        self = Nullable.literal(value)
    }
}


// MARK: - FloatLiteralConvertible

extension Nullable: FloatLiteralConvertible {
    init(floatLiteral value: Double) {
        self = Nullable.literal(value)
    }
}


// MARK: - ArrayLiteralConvertible

extension Nullable: ArrayLiteralConvertible {
    init(arrayLiteral elements: AnyObject...) {
        self = Nullable.literal(elements)
    }
}


// MARK: - DictionaryLiteralConvertible

extension Nullable: DictionaryLiteralConvertible {
    init(dictionaryLiteral elements: (String, AnyObject)...) {
        var dict: [String: AnyObject] = [:]
        for element in elements {
            dict[element.0] = element.1
        }
        self = Nullable.literal(dict)
    }
}
