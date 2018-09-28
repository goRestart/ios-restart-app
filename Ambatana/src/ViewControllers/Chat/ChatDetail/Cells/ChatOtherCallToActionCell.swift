import UIKit
import LGCoreKit
import LGComponents

final class ChatOtherCallToActionCell: ChatBubbleCell, ReusableCell {

    var bubbleBottomMargin: NSLayoutConstraint?
    var bubbleLeftMargin: NSLayoutConstraint?
    
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
        return view
    }()
    
    private let titleLabelAboveImage: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemBoldFont(size: 17)
        label.textColor = .blackText
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label
    }()
    
    private let ctaImageView: UIImageView = {
        let ctaImageView = UIImageView()
        ctaImageView.contentMode = .scaleAspectFit
        ctaImageView.clipsToBounds = true
        return ctaImageView
    }()
    
    private let titleLabelBelowImage: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemBoldFont(size: 17)
        label.textColor = .blackText
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label
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
    
    private let ctasContainer: UIStackView = {
        let stackView = UIStackView.vertical()
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = Metrics.veryShortMargin
        return stackView
    }()
    
    private var avatarAction: (() -> Void)?
    
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
    weak var reloadDelegate: ChatReloadCellDelegate?
    
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
        setupCTAButtons(ctas: ctas)
        messageLabel.text = ctaData.text
        dateLabel.text = dateText
        
        if let imagePosition = ctaData.image?.position, imagePosition == .down {
            self.titleLabelBelowImage.text = ctaData.title
        } else {
            self.titleLabelAboveImage.text = ctaData.title
        }
        
        if let ctaImageUrl = ctaData.image?.imageURL {
            ctaImageView.lg_setImageWithURL(ctaImageUrl, placeholderImage: nil) { [weak self] (result, url) in
                guard let strongSelf = self else { return }
                strongSelf.ctaImageView.image = result.value?.image
                strongSelf.reloadDelegate?.reload(cell: strongSelf)
            }
        }
    }
    
    func set(bubbleBackgroundColor: UIColor?) {
        guard let bubbleBackgroundColor = bubbleBackgroundColor else { return }
        bubbleView.backgroundColor = bubbleBackgroundColor
    }
    
    func configure(for position: ChatBubbleCellPosition) {
        configure(for: position, type: .callToAction)
        
        avatarImageView.isHidden = avatarImageView.image != nil ? !position.showOtherUserAvatar : true
        let avatarSpace = (2 * ChatBubbleLayout.margin + ChatBubbleLayout.avatarSize)
        bubbleLeftMargin?.constant = avatarImageView.image != nil ? avatarSpace : ChatBubbleLayout.margin
    }
    
    func set(userAvatar: UIImage?, avatarAction: (() -> Void)?) {
        avatarImageView.image = userAvatar
        self.avatarAction = avatarAction
        if let _ = avatarAction {
            avatarImageView.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
            avatarImageView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubviewsForAutoLayout([bubbleView, avatarImageView, titleLabelAboveImage, ctaImageView,
                                              titleLabelBelowImage, messageLabel, dateLabel, ctasContainer])
        setupConstraints()
    }
    
    private func setupConstraints() {
        bubbleBottomMargin = bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.veryShortMargin)
        bubbleBottomMargin?.isActive = true
        bubbleLeftMargin = bubbleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin)
        bubbleLeftMargin?.isActive = true
        
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -ChatBubbleLayout.minBubbleMargin-ChatBubbleLayout.avatarSize),
            bubbleView.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: ChatBubbleLayout.margin),
            ])
        
        NSLayoutConstraint.activate([
            titleLabelAboveImage.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: ChatBubbleLayout.bigMargin),
            titleLabelAboveImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            titleLabelAboveImage.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            titleLabelAboveImage.bottomAnchor.constraint(equalTo: ctaImageView.topAnchor),
            ctaImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            ctaImageView.rightAnchor.constraint(lessThanOrEqualTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            ctaImageView.bottomAnchor.constraint(equalTo: titleLabelBelowImage.topAnchor),
            titleLabelBelowImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            titleLabelBelowImage.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            titleLabelBelowImage.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -Metrics.veryShortMargin),
            messageLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            messageLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            messageLabel.bottomAnchor.constraint(equalTo: ctasContainer.topAnchor, constant: -Metrics.veryShortMargin),
            ctasContainer.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            ctasContainer.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.bigMargin),
            ctasContainer.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -Metrics.veryShortMargin),
            dateLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            dateLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.margin),
            dateLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -ChatBubbleLayout.margin),
            ])
    }
    
    private func setupCTAButtons(ctas: [ChatCallToAction]?) {
        guard let ctas = ctas else { return }
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
        ctas = []
        ctaImageView.image = nil
        titleLabelAboveImage.text = nil
        titleLabelBelowImage.text = nil
        messageLabel.text = nil
        ctasContainer.arrangedSubviews.forEach { [weak self] view in
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
