import UIKit
import LGComponents

protocol ChatBannerDelegate: class {
    func chatBannerDidFinish()
}

class ChatBanner: UIView {

    static let actionButtonMinimumWidth: CGFloat = 80

    weak var delegate: ChatBannerDelegate?
    private var action: UIAction?


    func setupChatBannerWith(_ title: String, action: UIAction?, buttonIcon: UIImage? = nil) {
        self.action = action
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayLight.cgColor
        backgroundColor = UIColor.white
        isHidden = true

        // subviews
        let titleLabel = UILabel()
        let actionButton = LetgoButton()
        let closeButton = UIButton()
        addSubview(titleLabel)
        addSubview(actionButton)
        addSubview(closeButton)

        // constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        var closeButtonSize: CGFloat = 0
        var closeButtonMargin: CGFloat = 0
        if DeviceFamily.current == .iPhone4 {
            closeButtonSize = 15
            closeButtonMargin = Metrics.margin
        }

        titleLabel.layout().width(Metrics.bigMargin, relatedBy: .greaterThanOrEqual)
        titleLabel.layout(with: self).centerY()
            .leftMargin(by: Metrics.margin)
            .top(by: Metrics.veryShortMargin, relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.veryShortMargin, relatedBy: .lessThanOrEqual)

        if let _ = action {
            actionButton.layout()
                .width(ChatBanner.actionButtonMinimumWidth, relatedBy: .greaterThanOrEqual)
                .height(LGUIKitConstants.smallButtonHeight)
        } else {
            actionButton.layout()
                .width(0)
                .height(LGUIKitConstants.smallButtonHeight)
        }

        actionButton.layout(with: self).centerY()
            .top(by: Metrics.veryShortMargin, relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.veryShortMargin, relatedBy: .lessThanOrEqual)
        actionButton.layout(with: titleLabel).left(to: .right, by: Metrics.shortMargin, relatedBy: .greaterThanOrEqual)

        closeButton.layout().width(closeButtonSize)
        closeButton.layout(with: self).centerY()
            .rightMargin(by: closeButtonMargin)
            .top(by: Metrics.veryShortMargin, relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.veryShortMargin, relatedBy: .lessThanOrEqual)
        closeButton.layout(with: actionButton).left(to: .right, by: Metrics.shortMargin)


        // Setup data
        // title label
        titleLabel.textColor = UIColor.grayText
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.mediumBodyFont
        titleLabel.text = title
        titleLabel.setContentHuggingPriority(749, for: .horizontal)
        // action button
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.titleLabel?.minimumScaleFactor = 0.8
        actionButton.setTitle(action?.text, for: .normal)
        actionButton.setStyle(action?.buttonStyle ?? .secondary(fontSize: .small, withBorder: true))
        if let buttonImage = buttonIcon {
            actionButton.setImage(buttonImage, for: .normal)
            actionButton.imageView?.contentMode = .scaleAspectFit
            actionButton.imageEdgeInsets = UIEdgeInsets(top: Metrics.veryShortMargin,
                                                        left: -Metrics.veryShortMargin,
                                                        bottom: Metrics.veryShortMargin,
                                                        right: 0)
        }
        actionButton.addTarget(self, action: #selector(bannerActionButtonTapped), for: .touchUpInside)
        actionButton.setContentCompressionResistancePriority(751, for: .horizontal)
        actionButton.set(accessibilityId: .chatBannerActionButton)

        closeButton.setImage(R.Asset.IconsButtons.icCloseDark.image, for: .normal)
        closeButton.addTarget(self, action: #selector(bannerCloseButtonTapped), for: .touchUpInside)
        closeButton.set(accessibilityId: .chatBannerCloseButton)
    }

    @objc private dynamic func bannerActionButtonTapped() {
        if let action = action {
            action.action()
        }
        delegate?.chatBannerDidFinish()
    }

    @objc private dynamic func bannerCloseButtonTapped() {
        delegate?.chatBannerDidFinish()
    }
}
