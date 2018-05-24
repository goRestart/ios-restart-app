import UIKit
import LGComponents

final class NativeAdBlankStateView: UIView {
    
    static let adsLightGrey = UIColor(rgb: 0xd5d3d3)
    private let adTextLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        cornerRadius = LGUIKitConstants.smallCornerRadius
        backgroundColor = NativeAdBlankStateView.adsLightGrey
        addSubviewsForAutoLayout([adTextLabel])

        adTextLabel.text = R.Strings.mopubAdvertisingText
        adTextLabel.font = UIFont.adTextFont
        adTextLabel.textColor = UIColor.white
        adTextLabel.textAlignment = .right
        adTextLabel.numberOfLines = 1
        adTextLabel.applyShadow(withOpacity: 0.5, radius: 4)
        adTextLabel.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        adTextLabel.layout(with: self)
            .fillHorizontal(by: Metrics.shortMargin)
            .bottom(by: -Metrics.veryShortMargin)
    }

}
