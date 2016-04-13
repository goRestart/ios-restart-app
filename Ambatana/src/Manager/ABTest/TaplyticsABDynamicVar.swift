//
//  TaplyticsABDynamicVar.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import Taplytics

public class TaplyticsABDynamicVar: ABDynamicVar {

    public var key: String
    public var type: ABType = .None

    public var defaultBoolValue = false
    public var defaultNumberValue = NSNumber()
    public var defaultStringValue = ""

    lazy var taplyticsVar: TaplyticsVar? = {
        return TaplyticsABDynamicVar.taplyticsVarFrom(self)
    }()


    // MARK: - var values

    public var boolValue: Bool {
        guard let value = taplyticsVar?.value as? NSNumber else { return defaultBoolValue }
        return value.boolValue
    }

    public var numberValue: NSNumber {
        guard let value = taplyticsVar?.value as? NSNumber else { return defaultNumberValue }
        return value
    }

    public var stringValue: String {
        guard let value = taplyticsVar?.value as? String else { return defaultStringValue }
        return value
    }


    // MARK: - var generation

    public static func boolVariable(key: String, boolValue: Bool) -> TaplyticsABDynamicVar {
        let variable = TaplyticsABDynamicVar(key: key, type: ABType.Bool)
        variable.defaultBoolValue = boolValue
        return variable
    }

    public static func numberVariable(key: String, numberValue: NSNumber) -> TaplyticsABDynamicVar  {
        let variable = TaplyticsABDynamicVar(key: key, type: ABType.Number)
        variable.defaultNumberValue = numberValue
        return variable
    }

    public static func stringVariable(key: String, stringValue: String) -> TaplyticsABDynamicVar  {
        let variable = TaplyticsABDynamicVar(key: key, type: ABType.String)
        variable.defaultStringValue = stringValue
        return variable
    }


    // MARK: - Private methods

    private init(key: String, type: ABType) {
        self.key = key
        self.type = type
    }

    private static func taplyticsVarFrom(variable: TaplyticsABDynamicVar) -> TaplyticsVar? {
        var taplyticsVar: TaplyticsVar!

        switch (variable.type) {
        case .Bool:
            taplyticsVar = TaplyticsVar.taplyticsSyncVarWithName(variable.key, defaultValue: variable.defaultBoolValue)
        case .Number:
            taplyticsVar = TaplyticsVar.taplyticsSyncVarWithName(variable.key, defaultValue: variable.defaultNumberValue)
        case .String:
            taplyticsVar = TaplyticsVar.taplyticsSyncVarWithName(variable.key, defaultValue: variable.defaultStringValue)
        case .None:
            return nil
        }
        return taplyticsVar
    }
}
