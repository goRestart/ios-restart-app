//
//  FloatingButton.swift
//  LetGo
//
//  Created by Albert Hernández López on 17/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

public class FloatingButton: UIButton {

    @IBOutlet weak var innerButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    public override var highlighted: Bool {
        didSet {
            innerButton.highlighted = highlighted
            iconImageView.highlighted = highlighted
        }
    }


    // MARK: - Lifecycle

    public static func floatingButton() -> FloatingButton? {
        guard let view = NSBundle.mainBundle().loadNibNamed("FloatingButton", owner: self, options: nil)?.first as? FloatingButton else { return nil }
        view.setupUIWithTitle(LGLocalizedString.tabBarToolTip, icon: UIImage(named: "ic_sell_white"))
        return view
    }
   
    override public func intrinsicContentSize() -> CGSize {
        let innerButtonRightMargin:CGFloat = 15
        let innerButtonWidth = innerButton.intrinsicContentSize().width
        let iconWidth = CGRectGetWidth(iconImageView.frame)
        let buttonHPadding:CGFloat = 20
        
        let width = innerButtonWidth + innerButtonRightMargin + iconWidth + buttonHPadding * 2
        return CGSize(width: width, height: 54)
    }
    
    // MARK: - Public methods
    
    public override func setTitle(title: String?, forState state: UIControlState) {
        setTitle(title)
    }
    
    public func setTitle(title: String?) {
        innerButton.setTitle(title, forState: .Normal)
        innerButton.sizeToFit()
    }
    
    public override func setImage(image: UIImage?, forState state: UIControlState) {
        setImage(image)
    }
    
    public func setImage(image: UIImage?) {
        iconImageView.image = image
    }
    
    // MARK: - Private methods
    
    private func setupUIWithTitle(title: String?, icon: UIImage?) {
        innerButton.setStyle(.Primary(fontSize: .Medium))
        innerButton.layer.cornerRadius = CGRectGetHeight(innerButton.frame) / 2

        setTitle(title)
        setImage(icon)
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 8.0
    }
}
