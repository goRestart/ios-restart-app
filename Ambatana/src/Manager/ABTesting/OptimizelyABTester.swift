//
//  OptimizelyABTesting.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import Optimizely

public class OptimizelyABTester: ABTester {
    
    static public let sharedInstance = OptimizelyABTester()
    
    public func setUserID(userID: String) {
        Optimizely.sharedInstance().userId = userID
    }
    
    public func setTag(tag: String, value: String) {
        Optimizely.setValue(value, forCustomTag: tag)
    }
    
    public func refreshExperiments() {
        Optimizely.refreshExperiments()
    }
    
    
    // MARK: > Live Variables
    
    public func registerLiveVariable(variable: ABLiveVariable) {
        guard let optVar = optimizelyVariableFrom(variable) else { return }
        Optimizely.preregisterVariableKey(optVar)
    }
    
    public func valueForVariable(variable: ABLiveVariable) -> Any? {
        guard let optVar = optimizelyVariableFrom(variable) else { return nil }
        switch (variable.type) {
        case .Bool:
            return Optimizely.boolForKey(optVar)
        case .Color:
            return Optimizely.colorForKey(optVar)
        case .Number:
            return Optimizely.numberForKey(optVar)
        case .Point:
            return Optimizely.pointForKey(optVar)
        case .Rect:
            return Optimizely.rectForKey(optVar)
        case .Size:
            return Optimizely.sizeForKey(optVar)
        case .String:
            return Optimizely.stringForKey(optVar)
        case .None:
            return nil
        }
    }
    
    public func registerCallbackForVariable(variable: ABLiveVariable, callback: (key: String, value: AnyObject) -> Void) {
        guard let optVar = optimizelyVariableFrom(variable) else { return }
        Optimizely.registerCallbackForVariableWithKey(optVar) { (key, value) -> Void in
            callback(key: key, value: value)
        }
    }
    
    
    // MARK: > Code Blocks
    
    public func registerCodeBlock(codeBlock: ABCodeBlock) {
        let blockKey = OptimizelyCodeBlocksKey(codeBlock.key, blockNames: codeBlock.blockNames)
        Optimizely.preregisterBlockKey(blockKey)
    }
    
    public func codeBlockWith(codeBlock: ABCodeBlock, blocksArray: [() -> ()], defaultBlock: () -> ()) {
        let blockKey = OptimizelyCodeBlocksKey(codeBlock.key, blockNames: codeBlock.blockNames)
        switch (blocksArray.count) {
        case 1:
            Optimizely.codeBlocksWithKey(blockKey, blockOne: blocksArray.first, defaultBlock: defaultBlock)
        case 2:
            Optimizely.codeBlocksWithKey(blockKey, blockOne: blocksArray[0], blockTwo: blocksArray[1], defaultBlock: defaultBlock)
        case 3:
            Optimizely.codeBlocksWithKey(blockKey, blockOne: blocksArray[0], blockTwo: blocksArray[1], blockThree: blocksArray[2], defaultBlock: defaultBlock)
        case 4:
            Optimizely.codeBlocksWithKey(blockKey, blockOne: blocksArray[0], blockTwo: blocksArray[1], blockThree: blocksArray[2], blockFour: blocksArray[3], defaultBlock: defaultBlock)
        default:
            break
        }
    }
    
    public func registerCallbackForCodeBlock(codeBlock: ABCodeBlock, callback: () -> ()) {
        let blockKey = OptimizelyCodeBlocksKey(codeBlock.key, blockNames: codeBlock.blockNames)
        Optimizely.registerCallbackForCodeBlockWithKey(blockKey, callback: callback)
    }
    
    
    // MARK: > Private Helpers
    
    private func optimizelyVariableFrom(variable: ABLiveVariable) -> OptimizelyVariableKey? {
        var optimizelyVar: OptimizelyVariableKey!
        
        switch (variable.type) {
        case .Bool:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultBOOL: variable.boolValue)
        case .Color:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultUIColor: variable.colorValue)
        case .Number:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultNSNumber: variable.numberValue)
        case .Point:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultCGPoint: variable.pointValue)
        case .Rect:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultCGRect: variable.rectValue)
        case .Size:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultCGSize: variable.sizeValue)
        case .String:
            optimizelyVar = OptimizelyVariableKey.optimizelyKeyWithKey(variable.key, defaultNSString: variable.stringValue)
        case .None:
            return nil
        }
        return optimizelyVar
    }
}