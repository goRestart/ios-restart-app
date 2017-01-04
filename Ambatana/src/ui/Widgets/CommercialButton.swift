//
//  VideoButton.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/3/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class CommercialButton: UIButton {
    
    @IBOutlet weak var innerButton: UIButton!
    @IBOutlet weak var icon: UIImageView!
    
    static func commercialButton() -> CommercialButton? {
        
        let view = Bundle.main.loadNibNamed("CommercialButton", owner: self, options: nil)?.first as? CommercialButton
        if let actualView = view {
            actualView.setupUI()
        }
        return view
    }
    
    override var intrinsicContentSize : CGSize {
        let innerButtonRightMargin: CGFloat = 8
        let innerButtonWidth = innerButton.intrinsicContentSize.width
        let iconWidth = icon.frame.width
        let buttonHPadding:CGFloat = 4
        
        let width = buttonHPadding + iconWidth + buttonHPadding*2 + innerButtonWidth + innerButtonRightMargin
        return CGSize(width: width, height: 32)
    }
    
    private func setupUI() {
        innerButton.setBackgroundImage(UIColor.white.imageWithSize(CGSize(width: 1, height: 1)), for: UIControlState())
        innerButton.setBackgroundImage(UIColor.grayLighter.imageWithSize(CGSize(width: 1, height: 1)), for: .highlighted)
        
        innerButton.layer.cornerRadius = innerButton.frame.height / 2
        innerButton.clipsToBounds = true
        innerButton.titleLabel?.font = UIFont.smallButtonFont
        innerButton.setTitle(LGLocalizedString.productOpenCommercialButton, for: UIControlState())
    }
}
