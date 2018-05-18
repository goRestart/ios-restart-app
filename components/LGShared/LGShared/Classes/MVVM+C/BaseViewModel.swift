//
//  BaseViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//


open class BaseViewModel {

    private var activeFirstTime = true
    var active: Bool = false {
        didSet {
            if oldValue != active {
                didSetActive(active)
                if active {
                    didBecomeActive(activeFirstTime)
                    activeFirstTime = false
                } else {
                    didBecomeInactive()
                }
            }
        }
    }

    public init() {
    }
    
    open func didSetActive(_ active: Bool) {
        
    }

    open func didBecomeActive(_ firstTime: Bool) {

    }

    open func didBecomeInactive() {

    }

    /*
     Called on standard back button press. Return false for native behavior or true if handled back internally
     Defaults to false
     */
    public func backButtonPressed() -> Bool {
        return false
    }
}
