//
//  ABDynamicVar.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum ABType {
    case bool
    case int
    case string
    case float
    case none
}

enum ABGroupType {
    case core
    case realEstate
    case money
    case retention
    case chat
}

protocol ABDynamicVar {
    associatedtype ValueType
    var key: String { get }
    var type: ABType { get }
    var value: ValueType { get }
    var defaultValue: ValueType { get }
    var lpVar: LPVar { get }
    var trackingData: String { get }
}

struct BoolABDynamicVar: ABDynamicVar, ABVariable {
    let key: String
    let type: ABType
    let defaultValue: Bool
    let lpVar: LPVar
    var value: Bool {
        return lpVar.boolValue()
    }
    let abGroupType: ABGroupType

    init(key: String, defaultValue: Bool, abGroupType: ABGroupType) {
        self.key = key
        self.type = .bool
        self.defaultValue = defaultValue
        self.lpVar = LPVar.define(key, with: defaultValue)
        self.abGroupType = abGroupType
    }
}

struct StringABDynamicVar: ABDynamicVar, ABVariable {
    let key: String
    let type: ABType
    let defaultValue: String
    let lpVar: LPVar
    var value: String {
        return lpVar.stringValue()
    }
    let abGroupType: ABGroupType

    init(key: String, defaultValue: String, abGroupType: ABGroupType) {
        self.key = key
        self.type = .string
        self.defaultValue = defaultValue
        self.lpVar = LPVar.define(key, with: defaultValue)
        self.abGroupType = abGroupType
    }
}

struct IntABDynamicVar: ABDynamicVar, ABVariable {
    let key: String
    let type: ABType
    let defaultValue: Int
    let lpVar: LPVar
    var value: Int {
        return lpVar.longValue()
    }
    let abGroupType: ABGroupType
    
    init(key: String, defaultValue: Int, abGroupType: ABGroupType) {
        self.key = key
        self.type = .int
        self.defaultValue = defaultValue
        self.lpVar = LPVar.define(key, withLong: defaultValue)
        self.abGroupType = abGroupType
    }
}

struct FloatABDynamicVar: ABDynamicVar, ABVariable {
    let key: String
    let type: ABType
    let defaultValue: Float
    let lpVar: LPVar
    var value: Float {
        return lpVar.floatValue()
    }
    let abGroupType: ABGroupType
    
    init(key: String, defaultValue: Float, abGroupType: ABGroupType) {
        self.key = key
        self.type = .float
        self.defaultValue = defaultValue
        self.lpVar = LPVar.define(key, with: defaultValue)
        self.abGroupType = abGroupType
    }
}

protocol ABVariable {
    var trackingData: String { get }
    var abGroupType: ABGroupType { get }
    func register()
}

extension ABDynamicVar {
    var trackingData: String {
        return "\(key)-\(value)"
    }
    func register() {
        let _ = self.value
    }
}
