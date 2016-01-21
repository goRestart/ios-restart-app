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
    let errorView = UIView()
    let errorLabel = UILabel()
    let errorIcon = UIImageView()
    
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
        addSubview(errorView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(errorIcon)
    }
    
    func setupUI() {
        nameLabel.font = StyleHelper.chatProductViewNameFont
        userLabel.font = StyleHelper.chatProductViewUserFont
        priceLabel.font = StyleHelper.chatProductViewPriceFont
        errorLabel.font = StyleHelper.chatProductViewUserFont
        
        nameLabel.textColor = StyleHelper.chatProductViewNameColor
        userLabel.textColor = StyleHelper.chatProductViewUserColor
        priceLabel.textColor = StyleHelper.chatProductViewPriceColor
        errorLabel.textColor = StyleHelper.chatProductViewNameColor
    
        errorLabel.textAlignment = .Center
        errorView.hidden = true
        errorView.backgroundColor = UIColor.whiteColor()
        separatorLine.backgroundColor = StyleHelper.lineColor
        imageButton.contentMode = .ScaleAspectFill
        imageButton.clipsToBounds = true
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
        
        errorView.frame = bounds
        errorView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        errorLabel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        errorIcon.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        
        separatorLine.frame = CGRect(x: 0, y: height - separatorHeight, width: width, height: separatorHeight)
        separatorLine.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
    }

    func showProductSoldError(errorString: String) {
        errorLabel.text = errorString
        errorLabel.textColor = StyleHelper.conversationProductSoldColor
        errorLabel.font = StyleHelper.conversationProductSoldFont
        errorIcon.image = UIImage(named: "oval45")
        showErrorView()
    }
    
    func showProductRemovedError(errorString: String) {
        errorLabel.text = errorString
        errorLabel.textColor = StyleHelper.conversationProductDeletedColor
        errorLabel.font = StyleHelper.conversationProductDeletedFont
        errorIcon.image = UIImage(named: "icAlertCopy")
        showErrorView()
    }
   
    func hideError() {
        UIView.animateWithDuration(0.25, animations: { [weak self] in
            self?.errorView.alpha = 0
        }) { [weak self] _ in
            self?.errorView.hidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private
    
    private func showErrorView() {
        repositionErrorView()
        UIView.animateWithDuration(0.25) { [weak self] in
            self?.errorView.alpha = 0.95
        }
    }
    
    private func repositionErrorView() {
        errorView.alpha = 0
        errorView.hidden = false
        errorLabel.sizeToFit()
        errorLabel.center = errorView.center
        errorIcon.left = errorLabel.left - errorIcon.width - 4
        errorIcon.centerY = errorLabel.centerY
    }
    
}
