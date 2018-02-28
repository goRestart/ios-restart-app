//
//  LGNavBarSearchField.swift
//  LetGo
//
//  Created by Dídac on 11/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

@IBDesignable
class LGNavBarSearchField: UIView {
    override var intrinsicContentSize: CGSize { return UILayoutFittingExpandedSize }

    var cleanCenterXConstraint: NSLayoutConstraint?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchTextField: LGTextField!
    @IBOutlet weak var magnifierIcon: UIImageView!
    @IBOutlet weak var logoIcon: UIImageView!
    
    @IBOutlet var magnifierIconLeadingConstraint: NSLayoutConstraint!

    var initialSearchValue = ""

    private var correctLayout : Bool {
        return self.frame.origin.x > 0.0
    }

    
    static func setupNavBarSearchFieldWithText(_ text: String?) -> LGNavBarSearchField {
        guard let view = Bundle.main.loadNibNamed("LGNavBarSearchField", owner: self, options: nil)?.first as?
            LGNavBarSearchField else { return LGNavBarSearchField() }
        view.setupCenterXConstraint()
        view.setupTextFieldWithText(text)
        view.endEdit()
        return view
    }

    private func setupCenterXConstraint() {
        cleanCenterXConstraint = magnifierIcon.leadingAnchor.constraint(equalTo: searchTextField.centerXAnchor)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupContentView()
        setupTextField()
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
        
        if let text = searchTextField.text, text.count > 0 {
            setupTextFieldEditMode()
        } else {
            setupTextFieldCleanMode()
        }
        searchTextField.resignFirstResponder()
    }
    
    
    // MARK: - Private Methods
    
    private func setupContentView() {
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.07)
        containerView.setRoundedCorners()
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
        logoIcon.isHidden = true
        magnifierIconLeadingConstraint.constant = Metrics.shortMargin
        magnifierIconLeadingConstraint.isActive = true
        cleanCenterXConstraint?.isActive = false

        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: { () -> Void in
            self.superview?.layoutIfNeeded()
            }, completion: { (completion) -> Void in
                self.logoIcon.isHidden = true
                self.searchTextField.showCursor = true
        })
    }
    
    /**
        Moves icons to make LGNavBarSearchField look not editable / clean
    */
    func setupTextFieldCleanMode(_ animated : Bool = true) {
        magnifierIconLeadingConstraint.isActive = false
        let width = logoIcon.width + magnifierIcon.width
        cleanCenterXConstraint?.constant = -width / 2.0
        cleanCenterXConstraint?.isActive = true

        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: { () -> Void in
            self.superview?.layoutIfNeeded()
            }, completion: { (completion) -> Void in
                self.logoIcon.isHidden = false
                self.searchTextField.showCursor = false
            }) 
    }

}
