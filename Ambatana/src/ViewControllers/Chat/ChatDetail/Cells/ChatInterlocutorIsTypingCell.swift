import Foundation
import LGComponents
import Lottie

class ChatInterlocutorIsTypingCell: UITableViewCell, ReusableCell {

    private let bubbleView = UIView()
    private let animationView = LOTAnimationView(name: "lottie_chat_typing_animation")

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

    var bubbleLeftMargin: NSLayoutConstraint?


    // MARK: - Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        backgroundColor = .clear

        contentView.addSubviewsForAutoLayout([bubbleView, avatarImageView])

        bubbleView.backgroundColor = .clear
        bubbleView.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        bubbleView.layer.shouldRasterize = true
        bubbleView.layer.rasterizationScale = UIScreen.main.scale
        bubbleView.backgroundColor = .chatOthersBubbleBgColorWhite

        bubbleView.addSubviewForAutoLayout(animationView)

        animationView.loopAnimation = true
        animationView.play()
    }

    private func setupConstraints() {
        var constraints = [
            avatarImageView.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -ChatBubbleLayout.minBubbleMargin),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.veryShortMargin),
            animationView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor)
            ]

        let bubbleLeft = bubbleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin)

        bubbleLeftMargin = bubbleLeft

        constraints.append(bubbleLeft)
        NSLayoutConstraint.activate(constraints)
    }

    @objc private func avatarTapped() {
        avatarAction?()
    }

    private func setupAccessibilityIds() {
        set(accessibilityId: .chatInterlocutorTypingCell)
        avatarImageView.set(accessibilityId: .chatCellAvatar)
    }
}
