//
//  KeyboardHelper.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

class KeyboardHelper {
    
    private(set) var keyboardHeight: CGFloat = 0
    private(set) var keyboardOrigin: CGFloat = 0
    private(set) var animationTime: CGFloat = 0.2
    private(set) var animationCurve: Int = 0
    static let sharedInstance = KeyboardHelper()
    private(set) var validFrame: Bool = false
    
    var rx_keyboardHeight = Variable<CGFloat>(0.0)
    var rx_keyboardOrigin = Variable<CGFloat>(0.0)
    var rx_keyboardVisible = Variable<Bool>(false)
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    dynamic func keyboardWillChange(notification: NSNotification) {
        keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue().height ?? 0
        keyboardOrigin = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue().origin.y ?? 0
        animationTime = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? CGFloat) ?? 0.25
        animationCurve = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Int) ?? 0
        
        rx_keyboardHeight.value = keyboardHeight
        rx_keyboardOrigin.value = keyboardOrigin
        rx_keyboardVisible.value = keyboardOrigin < UIScreen.mainScreen().bounds.height
    }
}

