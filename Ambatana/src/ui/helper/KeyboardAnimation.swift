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
    let duration: TimeInterval
    
    init(keyboardNotification notification: Notification) {
        let sizeObject = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]
        self.size = (sizeObject as AnyObject).cgRectValue ?? CGRect.zero
        if let optionsRaw = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            self.options = UIViewAnimationOptions(rawValue: optionsRaw)
        } else {
            self.options = UIViewAnimationOptions.curveEaseIn
        }
        self.duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
    }
}
