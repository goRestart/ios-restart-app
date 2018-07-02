import UIKit
import LGComponents

final class ChatMyMessageCell: ChatBubbleCell, ReusableCell {

    struct Layout {
        static let disclosureHeight: CGFloat = 13
        static let disclosureWidth: CGFloat = 8
    }

    let bubbleView: UIView = {
        let view = UIView()
        view.cornerRadius = LGUIKitConstants.mediumCornerRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        view.backgroundColor = .chatMyBubbleBgColor
        return view
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bigBodyFont
        label.textColor = UIColor.blackText
        label.numberOfLines = 0                     
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.smallBodyFontLight
        label.textColor = UIColor.darkGrayText
        return label
    }()

    let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icCheckSent.image
        return imageView
    }()

    let disclosureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icDisclosureChat.image
        return imageView
    }()

    var marginRightConstraints: [NSLayoutConstraint] = []
    var bubbleBottomMargin: NSLayoutConstraint?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setAccessibilityIds()
        NotificationCenter.default.addObserver(self, selector: #selector(menuControllerWillHide(_:)),
                                               name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func menuControllerWillHide(_ notification: Notification) {
        setSelected(false, animated: true)
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([bubbleView, messageLabel, dateLabel, checkImageView, disclosureImageView])
        setupConstraints()
        backgroundColor = .clear
    }

    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            bubbleView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: ChatBubbleLayout.minBubbleMargin),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            bubbleView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Metrics.shortMargin),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: Metrics.shortMargin),
            messageLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: Metrics.shortMargin),
            dateLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            dateLabel.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.dateHeight),
            dateLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: Metrics.shortMargin),
            dateLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -Metrics.shortMargin),
            checkImageView.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.checkImageSize),
            checkImageView.widthAnchor.constraint(equalToConstant: ChatBubbleLayout.checkImageSize),
            checkImageView.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: Metrics.shortMargin),
            checkImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -Metrics.shortMargin),
            disclosureImageView.widthAnchor.constraint(equalToConstant: Layout.disclosureHeight),
            disclosureImageView.heightAnchor.constraint(equalToConstant: Layout.disclosureWidth),
            disclosureImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disclosureImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -Metrics.margin)
        ]

        let labelRight = messageLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -Metrics.shortMargin)
        let imageRight = checkImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -Metrics.shortMargin)
        let bubbleBottom = bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.veryShortMargin)

        bubbleBottomMargin = bubbleBottom
        marginRightConstraints = [labelRight, imageRight]

        constraints.append(contentsOf: [labelRight, imageRight, bubbleBottom])
        NSLayoutConstraint.activate(constraints)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleView.backgroundColor = selected ? UIColor.chatMyBubbleBgColorSelected : UIColor.chatMyBubbleBgColor
    }
    
    private func setAccessibilityIds() {
        setDefaultAccessibilityIds()
        set(accessibilityId: .chatCellContainer(type: .myMessage))
    }
}
