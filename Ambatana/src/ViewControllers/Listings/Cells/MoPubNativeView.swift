import UIKit
import MoPub
import LGComponents

final class MoPubNativeView: UIView, MPNativeAdRendering {
    
    private var titleLabel = UILabel()
    private var privacyImageView = UIImageView()
    private var mainImageView = UIImageView()
    private var mainTextLabel = UILabel()
    private var callToActionLabel = UILabel()
    private var adTextLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupTitleLabel() {
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.adTitleFont
        titleLabel.textColor = UIColor.darkGrayText
        titleLabel.layout(with: self)
            .top(to: .topMargin)
            .left(to: .leftMargin)
        titleLabel.layout(with: privacyImageView)
            .toRight(by: Metrics.veryShortMargin)
    }
    
    private func setupMainTextLabel() {
        mainTextLabel.numberOfLines = 3
        mainTextLabel.font = UIFont.adDescriptionFont
        mainTextLabel.textColor = UIColor.darkGrayText
        mainTextLabel.layout(with: self)
            .left(to: .leftMargin)
            .right(to: .rightMargin)
        mainTextLabel.layout(with: mainImageView).below(by: Metrics.shortMargin)
        mainTextLabel.layout(with: callToActionLabel).above(by: -Metrics.shortMargin, relatedBy: .lessThanOrEqual)
    }
    
    private func setupCallToActionLabel() {
        callToActionLabel.numberOfLines = 1
        callToActionLabel.font = UIFont.adCallToActionFont
        callToActionLabel.backgroundColor = UIColor.white
        callToActionLabel.textColor = UIColor.primaryColor
        callToActionLabel.textAlignment = .center
        callToActionLabel.layer.borderColor = UIColor.primaryColor.cgColor
        callToActionLabel.layer.borderWidth = 1.0
        callToActionLabel.layout(with: self)
            .left(to: .leftMargin)
            .right(to: .rightMargin)
        callToActionLabel.layout().height(32)
        callToActionLabel.layout(with: adTextLabel).above(by: -Metrics.veryShortMargin)
        
    }
    
    private func setupPrivacyImage() {
        privacyImageView.layout(with: self)
            .top(to: .topMargin)
            .right(to: .rightMargin)
        privacyImageView.layout().width(24).widthProportionalToHeight()
    }
    
    private func setupMainImage() {
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.layout(with: self).left().right()
        mainImageView.layout(with: titleLabel).below(by: Metrics.shortMargin)
    }
    
    private func setupAdTextLabel() {
        adTextLabel.text = R.Strings.advertisingText
        adTextLabel.font = UIFont.adTextFont
        adTextLabel.textColor = UIColor.grayText
        adTextLabel.textAlignment = .right
        adTextLabel.numberOfLines = 1
        
        adTextLabel.layout(with: self)
            .left(to: .leftMargin)
            .right(to: .rightMargin)
            .bottom(by: -Metrics.veryShortMargin)
    }
    
    private func setupUI() {
        cornerRadius = LGUIKitConstants.smallCornerRadius
        backgroundColor = UIColor.white
        addSubviewsForAutoLayout([titleLabel, privacyImageView, mainImageView, mainTextLabel, callToActionLabel, adTextLabel])
        setupTitleLabel()
        setupPrivacyImage()
        setupMainTextLabel()
        setupMainImage()
        setupCallToActionLabel()
        setupAdTextLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        callToActionLabel.setRoundedCorners()
    }

}

extension MoPubNativeView {
    
    func nativeMainTextLabel() -> UILabel? {
        return mainTextLabel
    }
    
    func nativeTitleTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func nativeCallToActionTextLabel() -> UILabel? {
        return callToActionLabel
    }
    
    func nativeMainImageView() -> UIImageView? {
        return mainImageView
    }
    
    func nativePrivacyInformationIconImageView() -> UIImageView? {
        return privacyImageView
    }
    
}
