//
//  LGNavBarSearchField.swift
//  LetGo
//
//  Created by Dídac on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class LGNavBarSearchField: UITextField {

    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    @IBInspectable var clearButtonOffset: CGFloat = 0
    
    private let clearButtonSide : CGFloat = 19
    
    private var isEditing : Bool = false
    private var viewUpdated : Bool = false
    private var iconContainerView : UIView = UIView()
    private var magnifierView : UIView = UIView()
    
//    public let UITextFieldTextDidBeginEditingNotification: String
//    public let UITextFieldTextDidEndEditingNotification: String
//    public let UITextFieldTextDidChangeNotification: String
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("beginEdit:"), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("endEdit:"), name: UITextFieldTextDidEndEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textChanged:"), name: UITextFieldTextDidChangeNotification, object: nil)
        
        self.textColor = StyleHelper.navBarTitleColor
        self.clearButtonMode = UITextFieldViewMode.Always
        self.clearButtonOffset = 5
        self.insetX = 30

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(insetX, insetY, CGRectGetWidth(bounds)-2*insetX-clearButtonSide/2, CGRectGetHeight(bounds)-2*insetY)
    }
    
//    // clear button position
//    override func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
//        let rect = CGRectMake(bounds.size.width-clearButtonSide-clearButtonOffset , CGRectGetMidY(bounds)-clearButtonSide/2, clearButtonSide, clearButtonSide)
//        return rect
//    }
    
    
    override func layoutSubviews() {
        if !viewUpdated {
            viewUpdated = true
            setupTextField()
        }
    }
    
    func setupTextField() {
        
        if isEditing {
            magnifierView = UIImageView(image: UIImage(named: "list_search"))
            magnifierView.frame = CGRectMake(5, 0, 20, self.frame.height-10)
            magnifierView.contentMode = .ScaleAspectFit
            
            magnifierView.center.y = self.center.y-5
            
            self.addSubview(magnifierView)
            
        } else {
            self.borderStyle = UITextBorderStyle.None
            self.layer.cornerRadius = 5
            self.layer.borderWidth = 1
            self.layer.borderColor = StyleHelper.lineColor.CGColor
            self.backgroundColor = StyleHelper.navBarSearchFieldBgColor
            self.tintColor = StyleHelper.textFieldTintColor
            
            // add magnifier icon & logo
            iconContainerView = addIconsInContainer()
            iconContainerView.center = CGPoint(x: self.center.x, y: self.center.y-5)
            self.addSubview(iconContainerView)
        }
        
        
    }
    
    // private Methods
    
    private func addIconsInContainer() -> UIView {
        
        let iconsContainer = UIView(frame: CGRectMake(0, 0, 90, self.frame.height-10))

        let magnifierIcon = UIImageView(image: UIImage(named: "list_search"))
        magnifierIcon.frame = CGRectMake(0, 0, 40, iconsContainer.frame.height)
        magnifierIcon.contentMode = .ScaleAspectFit
        
        let logoIcon = UIImageView(image: UIImage(named: "navbar_logo"))
        logoIcon.frame = CGRectMake(40, 0, 50, iconsContainer.frame.height)
        logoIcon.contentMode = .ScaleAspectFit

        iconsContainer.addSubview(magnifierIcon)
        iconsContainer.addSubview(logoIcon)
        
        return iconsContainer
    }

    func beginEdit(notification: NSNotification) {
        
        isEditing = true
        iconContainerView.removeFromSuperview()
        viewUpdated = false
        
    }

    func endEdit(notification: NSNotification) {
        
        isEditing = false
        magnifierView.removeFromSuperview()
        viewUpdated = false
        self.resignFirstResponder()
    }
    
    func textChanged(notification: NSNotification) {
        
        if self.text?.characters.count > 0 {
            isEditing = true
//            self.setNeedsLayout()
        } else {
            self.resignFirstResponder()
            isEditing = false
//            self.setNeedsLayout()
//            self.layoutSubviews()
        }
        
    }

}
