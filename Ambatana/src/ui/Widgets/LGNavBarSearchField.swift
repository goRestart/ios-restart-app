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

    private var correctLayout : Bool {
        return self.frame.origin.x > 0.0
    }
    
    // First layout is not positioned correctly so if we try to animate when incorrect, we just wait until is correct
    private var pendingLayout = false
    private var editMode = false
    
    public static func setupNavBarSearchFieldWithText(text: String?) -> LGNavBarSearchField {
        guard let view = NSBundle.mainBundle().loadNibNamed("LGNavBarSearchField", owner: self, options: nil).first as?
            LGNavBarSearchField else { return LGNavBarSearchField() }
        view.setupTextFieldWithText(text)
        view.endEdit()
        return view
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if correctLayout && pendingLayout {
            if editMode {
                setupTextFieldEditMode(false)
            }
            else {
                setupTextFieldCleanMode(false)
            }
        }
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
        
        searchTextField.textColor = UIColor.lightBarTitle
        searchTextField.clearButtonMode = UITextFieldViewMode.Always
        searchTextField.clearButtonOffset = 5
        searchTextField.insetX = 30
        
        searchTextField.borderStyle = UITextBorderStyle.None
        searchTextField.layer.cornerRadius = searchTextField.frame.height/2
        searchTextField.backgroundColor = UIColor.black.colorWithAlphaComponent(0.07)
        
        
        if let actualText = text {
            initialSearchValue = actualText
        }
        
        searchTextField.text = initialSearchValue
        
    }
    
    /**
        Moves icons to make LGNavBarSearchField look editable
    */
    func setupTextFieldEditMode(animated : Bool = true) {
        editMode = true
        
        guard correctLayout else {
            pendingLayout = true
            return
        }
        pendingLayout = false
        
        logoIcon.hidden = true
        self.magnifierIconLeadingConstraint.constant = CGFloat(10)
        

        UIView.animateWithDuration(animated ? 0.2 : 0.0, animations: { () -> Void in

            self.layoutIfNeeded()

            }) { (completion) -> Void in
                self.logoIcon.hidden = true
                self.searchTextField.showCursor = true
        }
        
    }
    
    /**
        Moves icons to make LGNavBarSearchField look not editable / clean
    */
    func setupTextFieldCleanMode(animated : Bool = true) {
        editMode = false
        
        guard correctLayout else {
            pendingLayout = true
            return
        }
        pendingLayout = false
        
        self.magnifierIconLeadingConstraint.constant = CGFloat((self.frame.width/2) - CGFloat((self.magnifierIcon.frame.size.width + self.logoIcon.frame.size.width)/2.0))

        
        UIView.animateWithDuration(animated ? 0.2 : 0.0, animations: { () -> Void in
            
            self.layoutIfNeeded()

            }) { (completion) -> Void in
                self.logoIcon.hidden = false
                self.searchTextField.showCursor = false
            }
    }
}
