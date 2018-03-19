//
//  UILayoutPriority.swift
//  LetGo
//
//  Created by Facundo Menzella on 21/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

extension UILayoutPriority: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: Float(max(min(value, 1000), 0)))
    }

    static func +(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        return UILayoutPriority(max(min(lhs.rawValue - rhs, 1000), 0))
    }

    static func -(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        return UILayoutPriority(max(min(lhs.rawValue - rhs, 1000), 0))
    }

}
