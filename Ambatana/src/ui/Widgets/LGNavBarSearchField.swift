//
//  LGNavBarSearchField.swift
//  LetGo
//
//  Created by Dídac on 11/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

@IBDesignable
public class LGNavBarSearchField: UIView {

    @IBOutlet weak var searchTextField: LGTextField!
    @IBOutlet weak var magnifierIcon: UIImageView!
    @IBOutlet weak var logoIcon: UIImageView!
    
    @IBOutlet var magnifierIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var magnifierIconCenterXConstraint: NSLayoutConstraint!

    public var initialSearchValue = ""
    
    
    public static func setupNavBarSearchFieldWithText(text: String?) -> LGNavBarSearchField? {
        let view = NSBundle.mainBundle().loadNibNamed("LGNavBarSearchField", owner: self, options: nil).first as? LGNavBarSearchField
        if let actualView = view {
            actualView.setupTextFieldWithText(text)
            actualView.endEdit()
        }
        return view
    }
    
    /**
        Puts LGNavBarSearchField in edit mode
    */
    
    func beginEdit() {
        setupTextFieldEditMode()
    }
    
    
    /**
        Visual update of the text field
    */
    
    func endEdit() {

        searchTextField.text = initialSearchValue
        
        if searchTextField.text?.characters.count > 0 {
            setupTextFieldEditMode()
        } else {
            setupTextFieldCleanMode()
        }
        searchTextField.resignFirstResponder()
    }
    
    
    // MARK: private Methods
    
    private func setupTextFieldWithText(text: String?) {
        
        backgroundColor = UIColor.clearColor()
        
        searchTextField.textColor = StyleHelper.navBarTitleColor
        searchTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        searchTextField.clearButtonOffset = 5
        searchTextField.insetX = 30
        
        searchTextField.borderStyle = UITextBorderStyle.None
        searchTextField.layer.cornerRadius = 4
        searchTextField.layer.borderWidth = StyleHelper.onePixelSize
        searchTextField.layer.borderColor = StyleHelper.navBarSearchBorderColor.CGColor
        searchTextField.backgroundColor = StyleHelper.navBarSearchFieldBgColor
        searchTextField.tintColor = StyleHelper.textFieldTintColor // UIColor.clearColor() //
        
        
        if let actualText = text {
            initialSearchValue = actualText
        }
        
        searchTextField.text = initialSearchValue
        
    }
    
    /**
        Moves icons to make LGNavBarSearchField look editable
    */
    func setupTextFieldEditMode() {
        
        logoIcon.hidden = true
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in

            self.magnifierIconLeadingConstraint.constant = CGFloat(10)
            self.layoutSubviews()

            }) { (completion) -> Void in
                self.logoIcon.hidden = true
        }
        
    }
    
    /**
        Moves icons to make LGNavBarSearchField look not editable / clean
    */
    func setupTextFieldCleanMode() {
        
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.magnifierIconLeadingConstraint.constant = CGFloat((self.frame.width/2) - CGFloat((self.magnifierIcon.frame.size.width + self.logoIcon.frame.size.width)/2.0))
            
            print(self.frame.width)
            print(self.magnifierIconLeadingConstraint.constant)
            
            self.layoutSubviews()

            }) { (completion) -> Void in
                self.logoIcon.hidden = false
        }
    }
}
