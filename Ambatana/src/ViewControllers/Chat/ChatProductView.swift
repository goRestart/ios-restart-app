//
//  ChatProductView.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class ChatProductView: UIView {
    
    let imageHeight: CGFloat = 64
    let imageWidth: CGFloat = 64
    let margin: CGFloat = 8
    let labelHeight: CGFloat = 20
    let separatorHeight: CGFloat = 0.5
    
    let imageButton = UIImageView()
    let nameLabel = UILabel()
    let userLabel = UILabel()
    let priceLabel = UILabel()
    let separatorLine = UIView()
    
    init() {
        super.init(frame: CGRectZero)
        addSubviews()
        positionElements()
        setupUI()
    }

    func addSubviews() {
        addSubview(imageButton)
        addSubview(nameLabel)
        addSubview(userLabel)
        addSubview(priceLabel)
        addSubview(separatorLine)
    }
    
    func setupUI() {
        nameLabel.font = StyleHelper.chatProductViewNameFont
        userLabel.font = StyleHelper.chatProductViewUserFont
        priceLabel.font = StyleHelper.chatProductViewPriceFont
        
        nameLabel.textColor = StyleHelper.chatProductViewNameColor
        userLabel.textColor = StyleHelper.chatProductViewUserColor
        priceLabel.textColor = StyleHelper.chatProductViewPriceColor
        
        separatorLine.backgroundColor = StyleHelper.lineColor
    }
    
    func positionElements() {
        backgroundColor = UIColor.whiteColor()
        
        imageButton.frame = CGRect(x: margin, y: margin, width: imageWidth, height: imageHeight)
        imageButton.autoresizingMask = [.FlexibleRightMargin]

        nameLabel.frame = CGRect(x: imageButton.right + margin, y: margin, width: width, height: labelHeight)
        nameLabel.autoresizingMask = [.FlexibleWidth]
        
        userLabel.frame = CGRect(x: nameLabel.left, y: nameLabel.bottom, width: width, height: labelHeight)
        userLabel.autoresizingMask = [.FlexibleWidth]
        
        priceLabel.frame = CGRect(x: nameLabel.left, y: userLabel.bottom, width: width, height: labelHeight)
        priceLabel.autoresizingMask = [.FlexibleWidth]
        
        separatorLine.frame = CGRect(x: 0, y: height - separatorHeight, width: width, height: separatorHeight)
        separatorLine.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
