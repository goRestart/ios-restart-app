//
//  KeyboardManager.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class KeyboardManager {
    
    var keyboardHeight: CGFloat = 0
    static let sharedInstance = KeyboardManager()
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:UIKeyboardWillShowNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:UIKeyboardWillHideNotification, object: nil);
    }

    dynamic func keyboardWillChange(notification: NSNotification) {
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        keyboardHeight = keyboardSize?.height ?? 0
    }
}
