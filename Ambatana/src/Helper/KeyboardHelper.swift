//
//  KeyboardHelper.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class KeyboardHelper {
    
    private(set) var keyboardHeight: CGFloat = 0
    private(set) var keyboardOrigin: CGFloat = 0
    private(set) var animationTime: CGFloat = 0.2
    private(set) var animationCurve: Int = 0
    static let sharedInstance = KeyboardHelper()
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:UIKeyboardWillShowNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:UIKeyboardWillHideNotification, object: nil);
    }

    dynamic func keyboardWillChange(notification: NSNotification) {
        keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().height ?? 0
        keyboardOrigin = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().origin.y ?? 0
        animationTime = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? CGFloat) ?? 0.25
        animationCurve = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Int) ?? 0
    }
}
