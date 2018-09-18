import UIKit
import GoogleMobileAds
import LGComponents

final class GoogleAdxNativeView: GADNativeContentAdView {
    
    @IBOutlet weak private var adTextLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override var nativeContentAd: GADNativeContentAd? {
        set {
            super.nativeContentAd = newValue
            guard let nativeContentAd = newValue else { return }
            guard let titleLabel = headlineView as? UILabel else { return }
            titleLabel.text = nativeContentAd.headline
            guard let mainTextLabel = bodyView as? UILabel else { return }
            mainTextLabel.text = nativeContentAd.body
            guard let mainImageView = imageView as? UIImageView, let images = nativeContentAd.images, let nativeAdImage = images.first as? GADNativeAdImage else { return }
            mainImageView.image = nativeAdImage.image
            guard let callToActionButton = callToActionView as? UIButton else { return }
            callToActionButton.setTitle(nativeContentAd.callToAction, for: UIControlState.normal)
        }
        get {
            return super.nativeContentAd
        }
    }
    private func setupUI() {
        cornerRadius = LGUIKitConstants.smallCornerRadius
        backgroundColor = UIColor.white
        setupTitleLabel()
        setupMainTextLabel()
        setupCallToActionButton()
        setupAdTextLabel()
    }
    
    private func setupTitleLabel() {
        guard let titleLabel = headlineView as? UILabel else { return }
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.adTitleFont
        titleLabel.textColor = UIColor.darkGrayText
    }
    
    private func setupMainTextLabel() {
        guard let mainTextLabel = bodyView as? UILabel else { return }
        mainTextLabel.numberOfLines = 3
        mainTextLabel.font = UIFont.adDescriptionFont
        mainTextLabel.textColor = UIColor.darkGrayText
    }
    
    private func setupCallToActionButton() {
        guard let callToActionButton = callToActionView as? UIButton else { return }
        callToActionButton.titleLabel?.font = UIFont.adCallToActionFont
        callToActionButton.backgroundColor = UIColor.white
        callToActionButton.tintColor = UIColor.primaryColor
        callToActionButton.layer.borderColor = UIColor.primaryColor.cgColor
        callToActionButton.layer.borderWidth = 1.0
        callToActionButton.isUserInteractionEnabled = false
    }

    private func setupAdTextLabel() {
        adTextLabel.text = R.Strings.advertisingText
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
