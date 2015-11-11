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
    
    private var iconContainerView : UIView = UIView()
    private var magnifierView : UIView = UIView()
    
//    public let UITextFieldTextDidBeginEditingNotification: String
//    public let UITextFieldTextDidEndEditingNotification: String
//    public let UITextFieldTextDidChangeNotification: String


    convenience init(frame: CGRect, text: String?) {
        self.init(frame: frame)
        setupTextFieldWithText(text)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTextFieldWithText("")
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
    
    // clear button position
    override func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        let rect = CGRectMake(bounds.size.width-clearButtonSide-clearButtonOffset , CGRectGetMidY(bounds)-clearButtonSide/2, clearButtonSide, clearButtonSide)
//        print("xxxxxxxxxxxxxx")
//        print(self.frame)
//        print(bounds)
//        print(rect)
        return rect
    }
    
    override func layoutSubviews() {
        iconContainerView.center = CGPoint(x: self.center.x, y: self.center.y-5)
    }
    
    func setupTextFieldWithText(text: String?) {
        
        self.textColor = StyleHelper.navBarTitleColor
        self.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.clearButtonOffset = 5
        self.insetX = 30
        
        self.borderStyle = UITextBorderStyle.None
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = StyleHelper.lineColor.CGColor
        self.backgroundColor = StyleHelper.navBarSearchFieldBgColor
        self.tintColor = StyleHelper.textFieldTintColor

        guard let actualText = text else {
            setupTextFieldCleanMode()
            return
        }
        
        self.text = actualText
        setupTextFieldEditMode()
        
    }
    
    // private Methods
    
    private func addIconsInContainer() -> UIView {
        
        print(self.frame)
        
        let iconsContainer = UIView(frame: CGRectMake(0, 0, 80, 20))
//        let iconsContainer = UIView()

//        let containerHeightConstraint = NSLayoutConstraint(item: iconsContainer, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30)
//        iconsContainer.addConstraint(containerHeightConstraint)
//        let containerWidthConstraint = NSLayoutConstraint(item: iconsContainer, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 90)
//        iconsContainer.addConstraint(containerWidthConstraint)
        
        
        let magnifierIcon = UIImageView(image: UIImage(named: "list_search"))
        magnifierIcon.frame = CGRectMake(0, 0, 30, iconsContainer.frame.height)
        magnifierIcon.contentMode = .ScaleAspectFit

        let logoIcon = UIImageView(image: UIImage(named: "navbar_logo"))
        logoIcon.frame = CGRectMake(30, 0, 50, iconsContainer.frame.height)
        logoIcon.contentMode = .ScaleAspectFit

        iconsContainer.addSubview(magnifierIcon)
        iconsContainer.addSubview(logoIcon)

        
//        let magnifierHeightConstraint = NSLayoutConstraint(item: magnifierIcon, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30)
//        magnifierIcon.addConstraint(magnifierHeightConstraint)
//        let magnifierWidthConstraint = NSLayoutConstraint(item: magnifierIcon, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30)
//        magnifierIcon.addConstraint(magnifierWidthConstraint)
//
//        let logoHeightConstraint = NSLayoutConstraint(item: logoIcon, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30)
//        logoIcon.addConstraint(logoHeightConstraint)
//        let logoWidthConstraint = NSLayoutConstraint(item: logoIcon, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60)
//        logoIcon.addConstraint(logoWidthConstraint)
//
//        
//        let leadingConstraint = NSLayoutConstraint(item: magnifierIcon, attribute: NSLayoutAttribute.LeadingMargin, relatedBy: NSLayoutRelation.Equal, toItem: iconsContainer, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
//        let trailingConstraint = NSLayoutConstraint(item: logoIcon, attribute: NSLayoutAttribute.TrailingMargin, relatedBy: NSLayoutRelation.Equal, toItem: iconsContainer, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
//        
//        magnifierIcon.addConstraint(leadingConstraint)
//        logoIcon.addConstraint(trailingConstraint)
        

        return iconsContainer
    }

    func beginEdit() {
        setupTextFieldEditMode()
    }

    func endEdit() {
        setupTextFieldCleanMode()
        self.resignFirstResponder()
    }

    func setupTextFieldEditMode() {
        iconContainerView.removeFromSuperview()
        
        magnifierView = UIImageView(image: UIImage(named: "list_search"))
        magnifierView.frame = CGRectMake(5, 0, 20, self.frame.height-10)
        magnifierView.contentMode = .ScaleAspectFit
        
        magnifierView.center.y = self.center.y-5
        
        self.addSubview(magnifierView)
    }
    
    func setupTextFieldCleanMode() {
        
        magnifierView.removeFromSuperview()
        
        // add magnifier icon & logo
        iconContainerView = addIconsInContainer()
        iconContainerView.center = CGPoint(x: self.center.x, y: self.center.y-5)
        self.addSubview(iconContainerView)
        
//        let horizontalConstraint = NSLayoutConstraint(item: iconContainerView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
//        self.addConstraint(horizontalConstraint)
//        let verticalConstraint = NSLayoutConstraint(item: iconContainerView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
//        self.addConstraint(verticalConstraint)
    }

}
