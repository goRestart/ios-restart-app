import UIKit
import GoogleMobileAds
import LGComponents

final class GoogleAdxNativeContentView: GADNativeContentAdView {
    
    private let adTitleLabel: UILabel = {
        let adTitleLabel = UILabel()
        adTitleLabel.font = UIFont.adTitleFont
        adTitleLabel.textColor = UIColor.darkGrayText
        adTitleLabel.textAlignment = .left
        adTitleLabel.numberOfLines = 0
        return adTitleLabel
    }()
    
    private let adMainImageView: UIImageView = {
        let adMainImageView = UIImageView()
        return adMainImageView
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
    
    override var nativeContentAd: GADNativeContentAd? {
        didSet {
            guard let nativeContentAd = nativeContentAd, let callToActionView = callToActionView else { return }
            adTitleLabel.text = nativeContentAd.headline
            adMainTextLabel.text = nativeContentAd.body
            if let images = nativeContentAd.images, let nativeAdImage = images.first as? GADNativeAdImage {
                adMainImageView.image = nativeAdImage.image
            }
            adCTALabel.text = nativeContentAd.callToAction?.capitalizedFirstLetterOnly
            nativeContentAd.register(self,
                                     clickableAssetViews: [GADNativeContentAdAssetID.callToActionAsset: callToActionView],
                                     nonclickableAssetViews: [:])
        }
    }
    
    private func setupUI() {
        cornerRadius = LGUIKitConstants.smallCornerRadius
        backgroundColor = UIColor.white
        addSubviewsForAutoLayout([adTitleLabel, adMainImageView, adMainTextLabel, adCTALabel, adTextLabel])
        setupTitleLabel()
        setupMainTextLabel()
        setupMainImage()
        setupCallToActionButton()
        setupAdTextLabel()
    }
    
    private func setupTitleLabel() {
        adTitleLabel.layout(with: self)
            .top(by: Metrics.veryShortMargin)
            .right(by: -Metrics.margin)
            .left(by: Metrics.veryShortMargin)
    }
    
    private func setupMainTextLabel() {
        adMainTextLabel.layout(with: self)
            .left(to: .leftMargin)
            .right(to: .rightMargin)
        adMainTextLabel.layout(with: adMainImageView).below(by: Metrics.veryShortMargin)
        adMainTextLabel.layout(with: adCTALabel).above(by: -Metrics.shortMargin, relatedBy: .equal)
    }
    
    private func setupCallToActionButton() {
        adCTALabel.layout(with: adTextLabel)
            .left(to: .leftMargin)
            .right(to: .rightMargin)
        adCTALabel.layout()
            .height(LGUIKitConstants.advertisementCallToActionHeight)
        adCTALabel.layout(with: adTextLabel).above(by: -Metrics.veryShortMargin)
        callToActionView = adCTALabel
    }

    private func setupAdTextLabel() {
        adTextLabel.layout().height(LGUIKitConstants.advertisementAdTextHeight)
        adTextLabel.layout(with: self)
            .fillHorizontal(by: Metrics.shortMargin)
            .bottom(by: -Metrics.veryShortMargin)
    }
    
    private func setupMainImage() {
        adMainImageView.layout(with: self).fillHorizontal()
        adMainImageView.layout(with: adTitleLabel).below(by: Metrics.veryShortMargin)
        adMainImageView.layout().widthProportionalToHeight(multiplier: LGUIKitConstants.advertisementImageAspectRatio)
    }
 
}
