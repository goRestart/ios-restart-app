//
//  ABTester.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import Optimizely
import UIKit


public protocol ABTester {
    
    typealias ABVarType: ABLiveVariable
    
    func setUserID(userID: String)
    func setTag(tag: String, value: String)
    func refreshExperiments()

    // MARK: > Live Variables
    func registerLiveVariable(variable: ABVarType)
    func registerCallbackForVariable(variable: ABVarType, callback: (key: String, value: AnyObject) -> Void)
    
    // MARK: > Code Blocks
    func registerCodeBlock(codeBlock: ABCodeBlock)
    func codeBlockWith(codeBlock: ABCodeBlock, blocksArray: [() -> ()], defaultBlock: () -> ())
    func registerCallbackForCodeBlock(codeBlock: ABCodeBlock, callback: () -> ())
}