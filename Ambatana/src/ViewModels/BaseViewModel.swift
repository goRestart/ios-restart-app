//
//  BaseViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

public class BaseViewModel {
    
    public var active: Bool = false {
        didSet {
            if (active) {
                didSetActive()
            }
            else {
                didSetInactive()
            }
        }
    }
    
    // MARK: - Internal methods
    
    internal func didSetActive() {
        
    }
    
    internal func didSetInactive() {
        
    }
}
