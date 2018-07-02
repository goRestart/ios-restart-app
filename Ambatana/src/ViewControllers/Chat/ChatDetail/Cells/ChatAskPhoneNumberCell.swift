import UIKit
import LGComponents

final class ChatAskPhoneNumberCell: ChatBubbleCell, ReusableCell {

    private struct Layout {
        static let buttonHeight: CGFloat = 30
    }

    let bubbleView: UIView = {
        let view = UIView()
        view.cornerRadius = LGUIKitConstants.mediumCornerRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        view.backgroundColor = .white
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

    let leavePhoneNumberButton: LetgoButton = {
        let button = LetgoButton(withStyle: ButtonStyle.secondary(fontSize: ButtonFontSize.medium, withBorder: true))
        button.setTitle(R.Strings.professionalDealerAskPhoneAddPhoneCellButton, for: .normal)
        return button
    }()

    var buttonAction: (() -> Void)?
    var bubbleBottomMargin: NSLayoutConstraint?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func leavePhoneNumberPressed() {
        buttonAction?()
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([bubbleView, messageLabel, dateLabel, leavePhoneNumberButton])
        leavePhoneNumberButton.addTarget(self, action: #selector(leavePhoneNumberPressed), for: .touchUpInside)
        setupConstraints()
        backgroundColor = .clear
    }

    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            bubbleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -ChatBubbleLayout.minBubbleMargin),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ChatBubbleLayout.margin),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: ChatBubbleLayout.margin),
            messageLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            messageLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.margin),
            dateLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            dateLabel.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.dateHeight),
            dateLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            leavePhoneNumberButton.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            leavePhoneNumberButton.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            leavePhoneNumberButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: ChatBubbleLayout.bigMargin),
            leavePhoneNumberButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -ChatBubbleLayout.bigMargin),
            leavePhoneNumberButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setAccessibilityIds() {
        setDefaultAccessibilityIds()
        set(accessibilityId: .chatCellContainer(type: .askPhoneNumber))
    }
}
