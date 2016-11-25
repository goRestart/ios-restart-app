//
//  BaseViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//


public class BaseViewModel {

    private var activeFirstTime = true
    public var active: Bool = false {
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
    
    // MARK: - Internal methods
    
    func didSetActive(active: Bool) {
        
    }

    func didBecomeActive(firstTime: Bool) {

    }

    func didBecomeInactive() {

    }


    /*
     Called on standard back button press. Return false for native behavior or true if handled back internally
     Defaults to false
     */
    func backButtonPressed() -> Bool {
        return false
    }
}
