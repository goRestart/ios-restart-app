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

public struct ABLiveVariable {
    var key: String
    var type: ABType = .None
    
    var boolValue: Bool = false
    var numberValue: NSNumber = NSNumber()
    var pointValue: CGPoint = CGPoint(x: 0, y: 0)
    var rectValue: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var sizeValue: CGSize = CGSize(width: 0, height: 0)
    var stringValue: String = ""
    var colorValue: UIColor = UIColor()
    
    private init(key: String, type: ABType) {
        self.key = key
        self.type = type
    }
    
    public static func boolVariable(key: String, boolValue: Bool) -> ABLiveVariable {
        var variable = ABLiveVariable(key: key, type: ABType.Bool)
        variable.boolValue = boolValue
        return variable
    }
    
    public static func numberVariable(key: String, numberValue: NSNumber) -> ABLiveVariable  {
        var variable = ABLiveVariable(key: key, type: ABType.Number)
        variable.numberValue = numberValue
        return variable
    }
    
    public static func pointVariable(key: String, pointValue: CGPoint) -> ABLiveVariable  {
        var variable = ABLiveVariable(key: key, type: ABType.Point)
        variable.pointValue = pointValue
        return variable
    }
    
    public static func rectVariable(key: String, rectValue: CGRect) -> ABLiveVariable  {
        var variable = ABLiveVariable(key: key, type: ABType.Rect)
        variable.rectValue = rectValue
        return variable
    }
    
    public static func sizeVariable(key: String, sizeValue: CGSize) -> ABLiveVariable  {
        var variable = ABLiveVariable(key: key, type: ABType.Size)
        variable.sizeValue = sizeValue
        return variable
    }
    
    public static func stringVariable(key: String, stringValue: String) -> ABLiveVariable  {
        var variable = ABLiveVariable(key: key, type: ABType.String)
        variable.stringValue = stringValue
        return variable
    }
    
    public static func colorVariable(key: String, colorValue: UIColor) -> ABLiveVariable  {
        var variable = ABLiveVariable(key: key, type: ABType.Color)
        variable.colorValue = colorValue
        return variable
    }
}

public struct ABCodeBlock {
    var key: String
    var blockNames: [String]
}
