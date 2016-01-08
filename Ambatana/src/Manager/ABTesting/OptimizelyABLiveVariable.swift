//
//  OptimizelyABLiveVariable.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import Optimizely

public class OptimizelyABLiveVariable: ABLiveVariable {
    
    public var key: String
    public var type: ABType = .None
    
    public var defaultBoolValue = false
    public var defaultNumberValue = NSNumber()
    public var defaultPointValue = CGPoint(x: 0, y: 0)
    public var defaultRectValue = CGRect(x: 0, y: 0, width: 0, height: 0)
    public var defaultSizeValue = CGSize(width: 0, height: 0)
    public var defaultStringValue = ""
    public var defaultColorValue = UIColor()
    
    lazy var optimizelyVar: OptimizelyVariableKey? = {
        return OptimizelyABLiveVariable.optimizelyVariableFrom(self)
    }()
    
    public var boolValue: Bool {
        return Optimizely.boolForKey(optimizelyVar)
    }
    
    public var numberValue: NSNumber {
        return Optimizely.numberForKey(optimizelyVar)
    }
 
    public var pointValue: CGPoint {
        return Optimizely.pointForKey(optimizelyVar)
    }
    
    public var rectValue: CGRect {
        return Optimizely.rectForKey(optimizelyVar)
    }
    
    public var sizeValue: CGSize {
        return Optimizely.sizeForKey(optimizelyVar)
    }
    
    public var stringValue: String {
        return Optimizely.stringForKey(optimizelyVar)
    }
    
    public var colorValue: UIColor {
        return Optimizely.colorForKey(optimizelyVar)
    }
    
    private init(key: String, type: ABType) {
        self.key = key
        self.type = type
    }
    
    public static func boolVariable(key: String, boolValue: Bool) -> OptimizelyABLiveVariable {
        let variable = OptimizelyABLiveVariable(key: key, type: ABType.Bool)
        variable.defaultBoolValue = boolValue
        return variable
    }
    
    public static func numberVariable(key: String, numberValue: NSNumber) -> OptimizelyABLiveVariable  {
        let variable = OptimizelyABLiveVariable(key: key, type: ABType.Number)
        variable.defaultNumberValue = numberValue
        return variable
    }
    
    public static func pointVariable(key: String, pointValue: CGPoint) -> OptimizelyABLiveVariable  {
        let variable = OptimizelyABLiveVariable(key: key, type: ABType.Point)
        variable.defaultPointValue = pointValue
        return variable
    }
    
    public static func rectVariable(key: String, rectValue: CGRect) -> OptimizelyABLiveVariable  {
        let variable = OptimizelyABLiveVariable(key: key, type: ABType.Rect)
        variable.defaultRectValue = rectValue
        return variable
    }
    
    public static func sizeVariable(key: String, sizeValue: CGSize) -> OptimizelyABLiveVariable  {
        let variable = OptimizelyABLiveVariable(key: key, type: ABType.Size)
        variable.defaultSizeValue = sizeValue
        return variable
    }
    
    public static func stringVariable(key: String, stringValue: String) -> OptimizelyABLiveVariable  {
        let variable = OptimizelyABLiveVariable(key: key, type: ABType.String)
        variable.defaultStringValue = stringValue
        return variable
    }
    
    public static func colorVariable(key: String, colorValue: UIColor) -> OptimizelyABLiveVariable  {
        let variable = OptimizelyABLiveVariable(key: key, type: ABType.Color)
        variable.defaultColorValue = colorValue
        return variable
    }
    
    // MARK: > Private Helpers
    
    private static func optimizelyVariableFrom(variable: OptimizelyABLiveVariable) -> OptimizelyVariableKey? {
        var optimizelyVar: OptimizelyVariableKey!
        
        switch (variable.type) {
        case .Bool:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultBOOL: variable.defaultBoolValue)
        case .Color:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultUIColor: variable.defaultColorValue)
        case .Number:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultNSNumber: variable.defaultNumberValue)
        case .Point:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultCGPoint: variable.defaultPointValue)
        case .Rect:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultCGRect: variable.defaultRectValue)
        case .Size:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultCGSize: variable.defaultSizeValue)
        case .String:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultNSString: variable.defaultStringValue)
        case .None:
            return nil
        }
        return optimizelyVar
    }
}
