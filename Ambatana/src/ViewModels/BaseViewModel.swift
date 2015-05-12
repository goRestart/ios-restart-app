//
//  BaseViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class BaseViewModel {
    
    var active: Bool = false {
        didSet {
            didSetActive(active)
        }
    }
    
    // MARK: - Internal methods
    
    internal func didSetActive(isActive: Bool) {
        
    }
    
    // MARK: - Private methods
    
    @objc private func applicationDidEnterBackground(notification: NSNotification) {
        active = false
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        active = true
    }
}
