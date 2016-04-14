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
    var value: ValueType { get }
}

struct BoolABDynamicVar: ABDynamicVar {
    var key: String
    var type: ABType
    var value: Bool
}

struct StringABDynamicVar: ABDynamicVar {
    var key: String
    var type: ABType
    var value: String
}

struct NumberABDynamicVar: ABDynamicVar {
    var key: String
    var type: ABType
    var value: NSNumber
}

extension ABDynamicVar {
    var taplyticsVar: TaplyticsVar {
        return TaplyticsVar.taplyticsSyncVarWithName(key, defaultValue: value as? NSObject)
    }

    var taplyticsValue: ValueType {
        return taplyticsVar.value as? ValueType ?? value
    }
}
