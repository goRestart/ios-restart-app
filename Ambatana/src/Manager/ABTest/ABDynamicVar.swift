//
//  ABDynamicVar.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Taplytics

public enum ABType {
    case Bool
    case Number
    case String
    case None
}

protocol ABDynamicVar {
    associatedtype ValueType
    var key: String { get }
    var type: ABType { get }
    var defaultValue: ValueType { get }
}

struct BoolABDynamicVar: ABDynamicVar {
    let key: String
    let type: ABType
    let defaultValue: Bool
}

struct StringABDynamicVar: ABDynamicVar {
    let key: String
    let type: ABType
    let defaultValue: String
}

struct NumberABDynamicVar: ABDynamicVar {
    let key: String
    let type: ABType
    let defaultValue: NSNumber
}

extension ABDynamicVar {
    var value: ValueType {
        guard let theValue = defaultValue as? NSObject else { return defaultValue }
        return TaplyticsVar.taplyticsSyncVarWithName(key, defaultValue: theValue)
            .value as? ValueType ?? defaultValue
    }
}
