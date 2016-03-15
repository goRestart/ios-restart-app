//
//  VideoButton.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/3/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class VideoButton: UIButton {
    
    @IBOutlet weak var innerButton: UIButton!
    @IBOutlet weak var icon: UIImageView!
    
    static func videoButton() -> VideoButton? {
        
        let view = NSBundle.mainBundle().loadNibNamed("VideoButton", owner: self, options: nil).first as? VideoButton
        if let actualView = view {
            actualView.setupUI()
        }
        return view
    }
    
    override func intrinsicContentSize() -> CGSize {
        let innerButtonRightMargin: CGFloat = 8
        let innerButtonWidth = innerButton.intrinsicContentSize().width
        let iconWidth = CGRectGetWidth(icon.frame)
        let buttonHPadding:CGFloat = 4
        
        let width = buttonHPadding + iconWidth + buttonHPadding*2 + innerButtonWidth + innerButtonRightMargin
        return CGSize(width: width, height: 32)
    }
    
    private func setupUI() {
        innerButton.setPrimaryStyle()
        innerButton.layer.cornerRadius = CGRectGetHeight(innerButton.frame) / 2
        innerButton.titleLabel?.font = StyleHelper.videoButtonFont
    }
}
