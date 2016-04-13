//
//  ABDynamicVar.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


public enum ABType {
    case Bool
    case Number
    case String
    case None
}

public protocol ABDynamicVar {
    var key: String { get }
    var type: ABType { get }
    var boolValue: Bool { get }
    var numberValue: NSNumber { get }
    var stringValue: String { get }
}
