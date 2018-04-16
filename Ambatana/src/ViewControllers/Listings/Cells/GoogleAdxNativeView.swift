//
//  GooogleAdxNativeView.swift
//  LetGo
//
//  Created by Kiko Gómez on 9/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class GoogleAdxNativeView: GADNativeContentAdView {
    
    @IBOutlet weak private var adTextLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override var nativeContentAd: GADNativeContentAd? {
        set {
            super.nativeContentAd = newValue
            guard let nativeContentAd = newValue else { return }
            (headlineView as! UILabel).text = nativeContentAd.headline
            (bodyView as! UILabel).text = nativeContentAd.body
            (imageView as! UIImageView).image = (nativeContentAd.images?.first as! GADNativeAdImage).image
            (callToActionView as! UIButton).setTitle(nativeContentAd.callToAction, for: UIControlState.normal)
        }
        get {
            return super.nativeContentAd
        }
    }
    func setupUI() {
        cornerRadius = LGUIKitConstants.smallCornerRadius
        backgroundColor = UIColor.white
        setupTitleLabel()
        setupMainTextLabel()
        setupCallToActionButton()
        setupAdTextLabel()
    }
    
    private func setupTitleLabel() {
        let titleLabel = headlineView as! UILabel
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.adTitleFont
        titleLabel.textColor = UIColor.darkGrayText
    }
    
    private func setupMainTextLabel() {
        let mainTextLabel = bodyView as! UILabel
        mainTextLabel.numberOfLines = 3
        mainTextLabel.font = UIFont.adDescriptionFont
        mainTextLabel.textColor = UIColor.darkGrayText
    }
    
    private func setupCallToActionButton() {
        let callToActionButton = callToActionView as! UIButton
        callToActionButton.titleLabel?.font = UIFont.adCallToActionFont
        callToActionButton.backgroundColor = UIColor.white
        callToActionButton.tintColor = UIColor.primaryColor
        callToActionButton.layer.borderColor = UIColor.primaryColor.cgColor
        callToActionButton.layer.borderWidth = 1.0
        callToActionButton.isUserInteractionEnabled = false
    }

    private func setupAdTextLabel() {
        adTextLabel.text = LGLocalizedString.mopubAdvertisingText
        adTextLabel.font = UIFont.adTextFont
        adTextLabel.textColor = UIColor.grayText
        adTextLabel.textAlignment = .right
        adTextLabel.numberOfLines = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        callToActionView?.setRoundedCorners()
    }
}
