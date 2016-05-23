//
//  KeyboardAnimation.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

/**
Represents a keyboard animation.
*/
struct KeyboardAnimation {
    let size: CGRect
    let options: UIViewAnimationOptions
    let duration: NSTimeInterval
    
    init(keyboardNotification notification: NSNotification) {
        let sizeObject = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]
        self.size = sizeObject?.CGRectValue ?? CGRectZero
        if let optionsRaw = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            self.options = UIViewAnimationOptions(rawValue: optionsRaw) ?? UIViewAnimationOptions.CurveEaseIn
        } else {
            self.options = UIViewAnimationOptions.CurveEaseIn
        }
        self.duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval ?? 0.25
    }
}
