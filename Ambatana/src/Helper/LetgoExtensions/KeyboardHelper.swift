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
    private(set) var keyboardOrigin: CGFloat = UIScreen.main.bounds.height
    private(set) var animationTime: CGFloat = 0.25
    private(set) var animationCurve: Int = 0
    
    var rx_keyboardHeight = Variable<CGFloat>(0.0)
    var rx_keyboardOrigin = Variable<CGFloat>(0.0)
    var rx_keyboardVisible = Variable<Bool>(false)
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    dynamic func keyboardWillChange(_ notification: Notification) {
        keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
        keyboardOrigin = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y ?? UIScreen.main.bounds.height
        animationTime = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? CGFloat) ?? 0.25
        animationCurve = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Int) ?? 0
        
        rx_keyboardHeight.value = keyboardHeight
        rx_keyboardOrigin.value = keyboardOrigin
        rx_keyboardVisible.value = keyboardOrigin < UIScreen.main.bounds.height
    }
}

