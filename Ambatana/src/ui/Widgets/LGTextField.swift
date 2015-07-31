//
//  LGTextField.swift
//  LetGo
//
//  Created by Dídac on 20/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

@IBDesignable
class LGTextField: UITextField {
    
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    @IBInspectable var clearButtonOffset: CGFloat = 0

    private let clearButtonSide : CGFloat = 19
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(insetX, insetY, CGRectGetWidth(bounds)-2*insetX-clearButtonSide/2, CGRectGetHeight(bounds)-2*insetY)
    }

    // clear button position
    override func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        var rect = CGRectMake(bounds.size.width-clearButtonSide-clearButtonOffset , CGRectGetMidY(bounds)-clearButtonSide/2, clearButtonSide, clearButtonSide)
        return rect
    }
    
    
    func setupTextField() {
//        self.font = UIFont.systemFontOfSize(15)
        self.borderStyle = UITextBorderStyle.None
        self.insetX = 16
        self.clearButtonOffset = 12
        self.tintColor = StyleHelper.textFieldTintColor
    }
}