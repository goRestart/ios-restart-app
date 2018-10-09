import UIKit
import GoogleMobileAds
import LGComponents

final class GoogleAdxNativeUnifiedView: GADUnifiedNativeAdView {
    
    private let tappableOverlayView = UIView()
    
    private let adTitleLabel: UILabel = {
        let adTitleLabel = UILabel()
        adTitleLabel.font = UIFont.adTitleFont
        adTitleLabel.textColor = UIColor.darkGrayText
        adTitleLabel.textAlignment = .left
        adTitleLabel.numberOfLines = 0
        return adTitleLabel
    }()
    
    private let adIconImageView: UIImageView = {
        let iconImageView = UIImageView()
        return iconImageView
    }()
    
    private let adMediaView: GADMediaView =  {
        let adMediaView = GADMediaView()
        return adMediaView
    }()
    
    private let adCTALabel: UILabel = {
        let adCTALabel = UILabel()
        adCTALabel.font = UIFont.adCallToActionFont
        adCTALabel.backgroundColor = UIColor.white
        adCTALabel.textColor = UIColor.primaryColor
        adCTALabel.textAlignment = .center
        adCTALabel.numberOfLines = 1
        adCTALabel.layer.borderColor = UIColor.primaryColor.cgColor
        adCTALabel.layer.borderWidth = 1.0
        adCTALabel.cornerRadius = 16.0
        return adCTALabel
    }()
    
    private let adMainTextLabel: UILabel = {
        let adMainTextLabel = UILabel()
        adMainTextLabel.numberOfLines = 0
        adMainTextLabel.font = UIFont.adDescriptionFont
        adMainTextLabel.textColor = UIColor.darkGrayText
        adMainTextLabel.adjustsFontSizeToFitWidth = true
        return adMainTextLabel
    }()
    
    private let adTextLabel: UILabel = {
        let adTextLabel = UILabel()
        adTextLabel.text = R.Strings.advertisingText
        adTextLabel.font = UIFont.adTextFont
        adTextLabel.textColor = UIColor.grayText
        adTextLabel.textAlignment = .right
        adTextLabel.numberOfLines = 1
        return adTextLabel
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupAdData() {
        guard let nativeAd = self.nativeAd, let callToActionView = self.callToActionView else { return }
        nativeAd.register(self,
                          clickableAssetViews: [.callToActionAsset: callToActionView],
                          nonclickableAssetViews: [.mediaViewAsset: adMediaView])
        
        adTitleLabel.text = nativeAd.headline
        if let iconImage = nativeAd.icon {
            adIconImageView.isHidden = false
            adIconImageView.layout()
                .height(LGUIKitConstants.advertisementAppIconHeight)
                .widthProportionalToHeight(multiplier: 1.0)
            adIconImageView.image = iconImage.image
        } else {
            adIconImageView.isHidden = true
            adIconImageView.layout()
                .height(0)
                .widthProportionalToHeight(multiplier: 1.0)
        }
        adMainTextLabel.text = nativeAd.body
        let ctaText = nativeAd.callToAction?.count == 0 ? R.Strings.advertisingDefaultCta : nativeAd.callToAction
        adCTALabel.text = ctaText?.capitalizedFirstLetterOnly
    }
    
    override var nativeAd: GADUnifiedNativeAd? {
        didSet {
            setupAdData()
        }
    }
    
    private func setupCTALabel() {
        adCTALabel.layout(with: adTextLabel)
            .left(to: .leftMargin)
            .right(to: .rightMargin)
        adCTALabel.layout()
            .height(LGUIKitConstants.advertisementCallToActionHeight)
        adCTALabel.layout(with: adTextLabel).above(by: -Metrics.veryShortMargin)
    }
    
    private func setupTappableOverlayView() {
        tappableOverlayView.layout(with: self).fill()
        callToActionView = tappableOverlayView
    }
    
    private func setupTitleLabel() {
        adTitleLabel.layout(with: self)
            .top(by: Metrics.veryShortMargin)
            .right(by: -Metrics.margin)
        adTitleLabel.layout(with: adIconImageView)
            .toLeft(by: Metrics.veryShortMargin)
    }
    
    private func setupIconImage() {
        adIconImageView.layout()
            .height(LGUIKitConstants.advertisementAppIconHeight)
            .widthProportionalToHeight(multiplier: 1.0)
        adIconImageView.layout(with: self)
            .top(by: Metrics.veryShortMargin)
            .left(by: Metrics.veryShortMargin)
        adIconImageView.cornerRadius = LGUIKitConstants.smallCornerRadius
    }
    
    private func setupMainTextLabel() {
        adMainTextLabel.layout(with: self)
            .left(to: .leftMargin)
            .right(to: .rightMargin)
        adMainTextLabel.layout(with: adMediaView).below(by: Metrics.veryShortMargin)
        adMainTextLabel.layout(with: adCTALabel).above(by: -Metrics.shortMargin, relatedBy: .equal)
    }
    
    private func setupAdTextLabel() {
        adTextLabel.layout().height(LGUIKitConstants.advertisementAdTextHeight)
        adTextLabel.layout(with: self)
            .fillHorizontal(by: Metrics.shortMargin)
            .bottom(by: -Metrics.veryShortMargin)
    }
    
    private func setupMediaView() {
        self.mediaView = adMediaView
        adMediaView.layout(with: self).fillHorizontal()
        adMediaView.layout(with: adTitleLabel).below(by: Metrics.veryShortMargin)
        adMediaView.layout(with: adIconImageView).below(by: Metrics.veryShortMargin, relatedBy: .greaterThanOrEqual)
        adMediaView.layout().widthProportionalToHeight(multiplier: LGUIKitConstants.advertisementImageAspectRatio)
    }
    
    private func setupUI() {
        cornerRadius = LGUIKitConstants.smallCornerRadius
        backgroundColor = UIColor.white
        addSubviewsForAutoLayout([adIconImageView, adTitleLabel, adMediaView, adMainTextLabel, adCTALabel, adTextLabel, tappableOverlayView])
        setupIconImage()
        setupTitleLabel()
        setupMediaView()
        setupMainTextLabel()
        setupCTALabel()
        setupAdTextLabel()
        setupTappableOverlayView()
    }
    
}

