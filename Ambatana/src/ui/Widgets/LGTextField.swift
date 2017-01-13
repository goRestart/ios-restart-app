//
//  LGTextField.swift
//  LetGo
//
//  Created by Dídac on 20/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation


class LGTextField: UITextField {
    
    var insetX: CGFloat = 0
    var insetY: CGFloat = 0
    var clearButtonOffset: CGFloat = 0
    var showCursor = true {
        didSet {
            if showCursor {
                self.tintColor = UIColor.primaryColor
            }
            else {
                self.tintColor = UIColor.clear
            }
        }
    }

    private let clearButtonSide : CGFloat = 19
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: insetX, y: insetY, width: bounds.width-2*insetX-clearButtonSide/2, height: bounds.height-2*insetY)
    }

    // clear button position
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let rect = CGRect(x: bounds.size.width-clearButtonSide-clearButtonOffset , y: bounds.midY-clearButtonSide/2, width: clearButtonSide, height: clearButtonSide)
        return rect
    }
    
    
    func setupTextField() {
        self.borderStyle = UITextBorderStyle.none
        self.insetX = 16
        self.clearButtonOffset = 12
        self.tintColor = UIColor.primaryColor
    }
}
