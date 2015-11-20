//
//  ABLiveVariable.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

public enum ABType {
    case Bool
    case Number
    case Point
    case Rect
    case Size
    case String
    case Color
    case None
}

public protocol ABLiveVariable {
    var key: String { get }
    var type: ABType { get }
    var boolValue: Bool { get }
    var numberValue: NSNumber { get }
    var pointValue: CGPoint  { get }
    var rectValue: CGRect { get }
    var sizeValue: CGSize { get }
    var stringValue: String { get }
    var colorValue: UIColor { get }
}


public struct ABCodeBlock {
    var key: String
    var blockNames: [String]
}
