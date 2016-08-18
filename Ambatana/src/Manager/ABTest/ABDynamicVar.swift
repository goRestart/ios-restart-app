//
//  ABDynamicVar.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

public enum ABType {
    case Bool
    case Int
    case String
    case None
}

protocol ABDynamicVar {
    associatedtype ValueType
    var key: String { get }
    var type: ABType { get }
    var value: ValueType { get }
    var defaultValue: ValueType { get }
    var lpVar: LPVar { get }
    var trackingData: (String, AnyObject)? { get }
}

struct BoolABDynamicVar: ABDynamicVar, ABTrackDataVar {
    let key: String
    let type: ABType
    let defaultValue: Bool
    let lpVar: LPVar
    var value: Bool {
        return lpVar.boolValue()
    }

    init(key: String, defaultValue: Bool) {
        self.key = key
        self.type = .Bool
        self.defaultValue = defaultValue
        self.lpVar = LPVar.define(key, withBool: defaultValue);
    }
}

struct StringABDynamicVar: ABDynamicVar, ABTrackDataVar {
    let key: String
    let type: ABType
    let defaultValue: String
    let lpVar: LPVar
    var value: String {
        return lpVar.stringValue()
    }

    init(key: String, defaultValue: String) {
        self.key = key
        self.type = .String
        self.defaultValue = defaultValue
        self.lpVar = LPVar.define(key, withString: defaultValue)
    }
}

struct IntABDynamicVar: ABDynamicVar, ABTrackDataVar {
    let key: String
    let type: ABType
    let defaultValue: Int
    let lpVar: LPVar
    var value: Int {
        return lpVar.longValue()
    }

    init(key: String, defaultValue: Int) {
        self.key = key
        self.type = .Int
        self.defaultValue = defaultValue
        self.lpVar = LPVar.define(key, withLong: defaultValue)
    }
}

protocol ABTrackDataVar {
    var trackingData: (String, AnyObject)? { get }
}

extension ABDynamicVar {
    var trackingData: (String, AnyObject)? {
        guard let value = value as? AnyObject else { return nil }
        return ("[Leanplum] \(key)", value)
    }
}
