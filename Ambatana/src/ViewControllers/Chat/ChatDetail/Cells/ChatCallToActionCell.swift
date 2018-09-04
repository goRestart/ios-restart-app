import UIKit
import LGCoreKit
import LGComponents

protocol ChatDeeplinkCellDelegate: class {
    func openDeeplink(url: URL, trackingKey: String?)
}

final class ChatCallToActionCell: ChatBubbleCell, ReusableCell {

    private enum Layout {
        static let ctaImageHeight: CGFloat = 150
        static let actionButtonsHeight: CGFloat = 30
        static let separatorLineHeight: CGFloat = 1
    }

    let bubbleView: UIView = {
        let view = UIView()
        view.cornerRadius = LGUIKitConstants.mediumCornerRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        view.backgroundColor = .chatOthersBubbleBgColorWhite
        view.applyDefaultShadow()
        return view
    }()

    private let titleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryColorHighlighted
        view.clipsToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .blackText
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label
    }()

    private let ctaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .bigBodyFont
        label.textColor = .blackText
        label.numberOfLines = 0
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .smallBodyFontLight
        label.textColor = .darkGrayText
        return label
    }()

    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .grayLight
        return view
    }()

    private let ctasContainer: UIStackView = {
        let stackView = UIStackView.vertical()
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = Metrics.veryShortMargin
        return stackView
    }()

    private var avatarAction: (()->Void)?

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = ChatBubbleLayout.avatarSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        imageView.isHidden = true
        return imageView
    }()

    private var ctas: [ChatCallToAction]?
    private var ctaData: ChatCallToActionData?

    weak var delegate: ChatDeeplinkCellDelegate?

    var bubbleBottomMargin: NSLayoutConstraint?
    private var bubbleLeftMargin: NSLayoutConstraint?
    private var ctaImageViewHeight: NSLayoutConstraint?
    private var ctaImageViewTop: NSLayoutConstraint?
    private var ctaImageViewBottom: NSLayoutConstraint?
    private var messageToDateConstraint: NSLayoutConstraint?
    private var titleToMessageConstraint: NSLayoutConstraint?
    private var activeImageConstraints: [NSLayoutConstraint] = []

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    func setupWith(ctaData: ChatCallToActionData, ctas: [ChatCallToAction], dateText: String?) {
        self.ctas = ctas
        self.ctaData = ctaData
        createButtonsFor(ctas: ctas)
        self.titleLabel.text = ctaData.title
        self.messageLabel.text = ctaData.text
        self.dateLabel.text = dateText

        guard let ctaImageUrl = ctaData.image?.imageURL,
            let imagePosition = ctaData.image?.position else { return }
        
        updateImageConstraints(imagePosition: imagePosition)
        ctaImageView.lg_setImageWithURL(ctaImageUrl, placeholderImage: nil) { [weak self] (result, url) in
            guard let strongSelf = self else { return }
            if let image = result.value?.image {
                strongSelf.ctaImageView.image = image
            } else {
                strongSelf.ctaImageViewHeight?.constant = 0
            }
        }
    }

    func set(bubbleBackgroundColor: UIColor?) {
        guard let bubbleBackgroundColor = bubbleBackgroundColor else { return }
        bubbleView.backgroundColor = bubbleBackgroundColor
    }

    func set(userAvatar: UIImage?, avatarAction: (()->Void)?) {
        avatarImageView.image = userAvatar
        avatarImageView.isHidden = userAvatar == nil
        let avatarSpace = (2 * ChatBubbleLayout.margin + ChatBubbleLayout.avatarSize)
        bubbleLeftMargin?.constant = userAvatar != nil ? avatarSpace : ChatBubbleLayout.margin

        self.avatarAction = avatarAction
        if let _ = avatarAction {
            avatarImageView.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
            avatarImageView.addGestureRecognizer(tapRecognizer)
        }
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([bubbleView, avatarImageView])
        bubbleView.addSubviewsForAutoLayout([titleContainer, ctaImageView, messageLabel, dateLabel, separatorLine,
                                             ctasContainer])
        titleContainer.addSubviewForAutoLayout(titleLabel)
        setupConstraints()
        backgroundColor = .clear
    }

    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            avatarImageView.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor,
                                              constant: -ChatBubbleLayout.minBubbleMargin),
            titleContainer.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            titleContainer.leftAnchor.constraint(equalTo: bubbleView.leftAnchor),
            titleContainer.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            titleLabel.leftAnchor.constraint(equalTo: titleContainer.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            titleLabel.rightAnchor.constraint(equalTo: titleContainer.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            ctaImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            ctaImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            messageLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            messageLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.margin),
            dateLabel.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.dateHeight),
            dateLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            separatorLine.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: ChatBubbleLayout.bigMargin),
            separatorLine.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            separatorLine.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            separatorLine.heightAnchor.constraint(equalToConstant: Layout.separatorLineHeight),
            ctasContainer.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            ctasContainer.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            ctasContainer.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: ChatBubbleLayout.bigMargin),
            ctasContainer.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -ChatBubbleLayout.bigMargin)
        ]

        let bubbleBottom = bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.veryShortMargin)
        let bubbleLeft = bubbleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin)

        bubbleBottomMargin = bubbleBottom
        bubbleLeftMargin = bubbleLeft

        let ctaImageHeightConstraint = ctaImageView.heightAnchor.constraint(equalToConstant: Layout.ctaImageHeight)
        ctaImageViewHeight = ctaImageHeightConstraint

        constraints.append(contentsOf: [bubbleBottom, bubbleLeft, ctaImageHeightConstraint])

        let imageConstraints = constraintsForImageUp()
        constraints.append(contentsOf: imageConstraints)

        NSLayoutConstraint.activate(constraints)
    }

    private func updateImageConstraints(imagePosition: ChatCallToActionImagePosition) {
        switch imagePosition {
        case .up:
            NSLayoutConstraint.deactivate(activeImageConstraints)
            NSLayoutConstraint.activate(constraintsForImageUp())
        case .down:
            NSLayoutConstraint.deactivate(activeImageConstraints)
            NSLayoutConstraint.activate(constraintsForImageDown())
        }
    }

    private func constraintsForImageUp() -> [NSLayoutConstraint] {
        let ctaImageTop = ctaImageView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor,
                                                            constant: ChatBubbleLayout.bigMargin)
        let ctaImageBottom = ctaImageView.bottomAnchor.constraint(equalTo: messageLabel.topAnchor,
                                                                  constant: -ChatBubbleLayout.bigMargin)

        ctaImageViewTop = ctaImageTop
        ctaImageViewBottom = ctaImageBottom

        let messageToDate = dateLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor,
                                                           constant: Metrics.veryShortMargin)
        messageToDateConstraint = messageToDate
        titleToMessageConstraint = nil

        let imageUpConstraints = [ctaImageTop, ctaImageBottom, messageToDate]

        activeImageConstraints = imageUpConstraints
        return imageUpConstraints
    }

    private func constraintsForImageDown() -> [NSLayoutConstraint] {
        let ctaImageTop = ctaImageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor,
                                                            constant: ChatBubbleLayout.bigMargin)
        let ctaImageBottom = ctaImageView.bottomAnchor.constraint(equalTo: dateLabel.topAnchor,
                                                                  constant: -ChatBubbleLayout.bigMargin)

        ctaImageViewTop = ctaImageTop
        ctaImageViewBottom = ctaImageBottom

        let titleToMessage = messageLabel.topAnchor.constraint(equalTo: titleContainer.bottomAnchor,
                                                               constant: Metrics.veryShortMargin)
        titleToMessageConstraint = titleToMessage

        messageToDateConstraint = nil

        let imageDownConstraints = [ctaImageTop, ctaImageBottom, titleToMessage]
        activeImageConstraints = imageDownConstraints
        return imageDownConstraints
    }

    private func createButtonsFor(ctas: [ChatCallToAction]) {
        ctas.enumerated().forEach { [weak self] (index, cta) in
            guard cta.content.deeplinkURL != nil else { return }
            let button = LetgoButton(withStyle: .primary(fontSize: .small))
            button.setTitle(cta.content.text, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(ctaButtonPressed(sender:)), for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: Layout.actionButtonsHeight).isActive = true
            self?.ctasContainer.addArrangedSubview(button)
        }
    }

    private func resetUI() {
        self.ctas = []
        self.ctaImageView.image = nil
        self.titleLabel.text = nil
        self.messageLabel.text = nil
        self.ctasContainer.arrangedSubviews.forEach { [weak self] view in
            self?.ctasContainer.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func setAccessibilityIds() {
        setDefaultAccessibilityIds()
        set(accessibilityId: .chatCellContainer(type: .callToAction))
        avatarImageView.set(accessibilityId: .chatCellAvatar)
    }

    @objc private func ctaButtonPressed(sender: LetgoButton) {
        let ctaIndex = sender.tag
        guard let cta = ctas?[safeAt: ctaIndex], let url = cta.content.deeplinkURL else { return }
        delegate?.openDeeplink(url: url, trackingKey: cta.key)
    }

    @objc private func avatarTapped() {
        avatarAction?()
    }
}
