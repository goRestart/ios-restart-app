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

//    convenience init(frame: CGRect, text: String?) {
//        self.init(frame: frame)
//        setupTextFieldWithText(text)
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    public static func setupNavBarSearchFieldWithText(text: String?) -> LGNavBarSearchField? {
        let view = NSBundle.mainBundle().loadNibNamed("LGNavBarSearchField", owner: self, options: nil).first as? LGNavBarSearchField
        if let actualView = view {
            actualView.setupTextFieldWithText(text)
        }
        return view
    }
    
    func setupTextFieldWithText(text: String?) {
        searchTextField.textColor = StyleHelper.navBarTitleColor
        searchTextField.clearButtonMode = UITextFieldViewMode.Always
        searchTextField.clearButtonOffset = 5
        searchTextField.insetX = 30
        
        searchTextField.borderStyle = UITextBorderStyle.None
        searchTextField.layer.cornerRadius = 5
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = StyleHelper.lineColor.CGColor
        searchTextField.backgroundColor = StyleHelper.navBarSearchFieldBgColor
        searchTextField.tintColor = StyleHelper.textFieldTintColor
        
//        guard let actualText = text else {
//            setupTextFieldCleanMode()
//            return
//        }
//        
//        print("setupTextFieldWithText")
//        print(actualText)
//        setupTextFieldEditMode()
        searchTextField.text = text
        
    }
    
    // private Methods
    
   
    func beginEdit() {
        setupTextFieldEditMode()
    }
    
    func endEdit() {
        if searchTextField.text?.characters.count > 0 {
            setupTextFieldEditMode()
        } else {
            setupTextFieldCleanMode()
        }
    }
    
    func setupTextFieldEditMode() {
        
        logoIcon.hidden = true
        
        UIView.animateWithDuration(1, animations: { () -> Void in

            self.magnifierIconCenterXConstraint.constant = CGFloat(-(self.frame.width/2) + 15)
            self.setNeedsLayout()
            
            }) { (completion) -> Void in
                
        }
        
    }
    
    func setupTextFieldCleanMode() {
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            
            self.magnifierIconCenterXConstraint.constant = CGFloat(-20)
            self.setNeedsLayout()
            
            }) { (completion) -> Void in
                self.logoIcon.hidden = false
        }

        searchTextField.resignFirstResponder()
    }
}
