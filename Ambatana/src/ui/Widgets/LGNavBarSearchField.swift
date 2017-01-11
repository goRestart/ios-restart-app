//
//  LGNavBarSearchField.swift
//  LetGo
//
//  Created by Dídac on 11/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@IBDesignable
class LGNavBarSearchField: UIView {

    @IBOutlet weak var searchTextField: LGTextField!
    @IBOutlet weak var magnifierIcon: UIImageView!
    @IBOutlet weak var logoIcon: UIImageView!
    
    @IBOutlet var magnifierIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var magnifierIconCenterXConstraint: NSLayoutConstraint!

    var initialSearchValue = ""

    private var correctLayout : Bool {
        return self.frame.origin.x > 0.0
    }
    
    // First layout is not positioned correctly so if we try to animate when incorrect, we just wait until is correct
    private var pendingLayout = false
    private var editMode = false
    
    static func setupNavBarSearchFieldWithText(_ text: String?) -> LGNavBarSearchField {
        guard let view = Bundle.main.loadNibNamed("LGNavBarSearchField", owner: self, options: nil)?.first as?
            LGNavBarSearchField else { return LGNavBarSearchField() }
        view.setupTextFieldWithText(text)
        view.endEdit()
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupContentView()
        setupTextField()
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
    
    
    // MARK: - Private Methods
    
    private func setupContentView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.07)
        layer.cornerRadius = searchTextField.frame.height/2
    }

    private func setupTextField() {
        searchTextField.borderStyle = UITextBorderStyle.none
        searchTextField.textColor = UIColor.lightBarTitle
        searchTextField.clearButtonMode = UITextFieldViewMode.always
        searchTextField.clearButtonOffset = 5
        searchTextField.insetX = 30
    }

    private func setupTextFieldWithText(_ text: String?) {
        if let actualText = text {
            initialSearchValue = actualText
        }
        searchTextField.text = initialSearchValue
    }
    
    /**
        Moves icons to make LGNavBarSearchField look editable
    */
    func setupTextFieldEditMode(_ animated : Bool = true) {
        editMode = true
        
        guard correctLayout else {
            pendingLayout = true
            return
        }
        pendingLayout = false
        
        logoIcon.isHidden = true
        self.magnifierIconLeadingConstraint.constant = CGFloat(10)
        

        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: { () -> Void in

            self.layoutIfNeeded()

            }, completion: { (completion) -> Void in
                self.logoIcon.isHidden = true
                self.searchTextField.showCursor = true
        }) 
        
    }
    
    /**
        Moves icons to make LGNavBarSearchField look not editable / clean
    */
    func setupTextFieldCleanMode(_ animated : Bool = true) {
        editMode = false
        
        guard correctLayout else {
            pendingLayout = true
            return
        }
        pendingLayout = false
        
        self.magnifierIconLeadingConstraint.constant = CGFloat((self.frame.width/2) - CGFloat((self.magnifierIcon.frame.size.width + self.logoIcon.frame.size.width)/2.0))

        
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: { () -> Void in
            
            self.layoutIfNeeded()

            }, completion: { (completion) -> Void in
                self.logoIcon.isHidden = false
                self.searchTextField.showCursor = false
            }) 
    }
}
