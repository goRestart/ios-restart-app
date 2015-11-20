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
    
    public typealias ABVarType = OptimizelyABLiveVariable
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
    
    public func registerLiveVariable(variable: ABVarType) {
        Optimizely.preregisterVariableKey(variable.optimizelyVar)
    }
    
    public func registerCallbackForVariable(variable: ABVarType, callback: (key: String, value: AnyObject) -> Void) {
        guard let optVar = variable.optimizelyVar else { return }
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
}