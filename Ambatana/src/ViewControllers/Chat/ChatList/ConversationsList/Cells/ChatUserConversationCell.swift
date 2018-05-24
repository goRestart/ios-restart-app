import Foundation
import UIKit
import Lottie
import LGComponents

final class ChatUserConversationCell: UITableViewCell, ReusableCell {

    struct Layout {
        static let listingImageViewHeight: CGFloat = 60
        static let userImageViewHeight: CGFloat = 38
        static let transactionBadgeHeight: CGFloat = 30
        static let pendingMessagesBadgeHeight: CGFloat = 18
        static let listingTitleLabelHeight: CGFloat = 18
        static let statusIconHeight: CGFloat = 12
        static let userTypingAnimationWidth: CGFloat = 40
        static let userTypingAnimationHeight: CGFloat = 24
    }

    private let listingImageView: ChatAvatarView = {
        let imageView = ChatAvatarView(mainCornerRadius: .custom(radius: 4),
                                       badgeStyle: .topLeft(height: Layout.transactionBadgeHeight),
                                       shareBounds: true)
        return imageView
    }()

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.cornerRadius = Layout.userImageViewHeight/2
        return imageView
    }()

    private let mainStackContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 20)
        stackView.spacing = 0
        return stackView
    }()

    private let textStackContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10)
        stackView.spacing = 5
        return stackView
    }()

    private let statusStackContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.spacing = 8
        return stackView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 17)
        label.textColor = .blackText
        label.textAlignment = .left
        return label
    }()

    private let listingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(size: 15)
        label.textColor = .grayText
        label.textAlignment = .left
        return label
    }()

    private let timeLastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemLightFont(size: 13)
        label.textColor = .grayText
        label.textAlignment = .left
        return label
    }()

    private let statusIcon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        return icon
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemLightFont(size: 13)
        label.textColor = .grayText
        label.textAlignment = .left
        return label
    }()

    private let pendingMessagesLabel: UIRoundedLabelWithPadding = {
        let label = UIRoundedLabelWithPadding()
        label.font = UIFont.systemBoldFont(size: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .primaryColor
        label.padding = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        return label
    }()

    private let userIsTypingAnimationView: LOTAnimationView = {
        let view = LOTAnimationView(name: "lottie_chat_typing_animation")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.loopAnimation = true
        return view
    }()
    private let userIsTypingAnimationViewContainer = UIView()


    // MARK: - Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    func setupUI() {
        contentView.backgroundColor = .white
        layoutMargins = .zero

        statusStackContainer.addArrangedSubview(statusIcon)
        statusStackContainer.addArrangedSubview(statusLabel)

        textStackContainer.addArrangedSubview(userNameLabel)
        textStackContainer.addArrangedSubview(listingTitleLabel)
        textStackContainer.addArrangedSubview(timeLastMessageLabel)

        mainStackContainer.addArrangedSubview(listingImageView)
        mainStackContainer.addArrangedSubview(textStackContainer)

        let rightContainerView = UIView()
        rightContainerView.addSubviewsForAutoLayout([userImageView, pendingMessagesLabel])
        userImageView.layout().height(Layout.userImageViewHeight).widthProportionalToHeight()

        let rightContainerConstraints = [
            userImageView.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor),
            userImageView.topAnchor.constraint(equalTo: rightContainerView.topAnchor),
            userImageView.trailingAnchor.constraint(equalTo: rightContainerView.trailingAnchor),
            pendingMessagesLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: -Metrics.shortMargin),
            pendingMessagesLabel.centerXAnchor.constraint(equalTo: rightContainerView.centerXAnchor),
            pendingMessagesLabel.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor)
        ]

        NSLayoutConstraint.activate(rightContainerConstraints)

        mainStackContainer.addArrangedSubview(rightContainerView)
    }

    func setupConstraints() {

        listingImageView.translatesAutoresizingMaskIntoConstraints = false
        pendingMessagesLabel.translatesAutoresizingMaskIntoConstraints = false

        listingImageView.layout().height(Layout.listingImageViewHeight).widthProportionalToHeight()
        pendingMessagesLabel.layout().height(Layout.pendingMessagesBadgeHeight)
        statusIcon.layout().height(Layout.statusIconHeight).widthProportionalToHeight()
        listingTitleLabel.layout().height(Layout.listingTitleLabelHeight)

        contentView.addSubviewForAutoLayout(mainStackContainer)

        let cellConstraints = [
            mainStackContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStackContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(cellConstraints)

        userIsTypingAnimationViewContainer.translatesAutoresizingMaskIntoConstraints = false
        userIsTypingAnimationViewContainer.backgroundColor = .grayBackground
        userIsTypingAnimationViewContainer.addSubview(userIsTypingAnimationView)
        userIsTypingAnimationViewContainer.layout()
            .width(Layout.userTypingAnimationWidth)
            .height(Layout.userTypingAnimationHeight)
        userIsTypingAnimationViewContainer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        userIsTypingAnimationView.layout(with: userIsTypingAnimationViewContainer)
            .fill()
    }

    func setAccessibilityIds() {
        timeLastMessageLabel.set(accessibilityId: .conversationCellTimeLabel)
        pendingMessagesLabel.set(accessibilityId: .conversationCellBadgeLabel)
        listingImageView.set(accessibilityId: .conversationCellThumbnailImageView)
        userImageView.set(accessibilityId: .conversationCellAvatarImageView)
        statusStackContainer.set(accessibilityId: .conversationCellStatusImageView)
    }

    func resetUI() {
        listingImageView.setMainImage(mainImage: nil)
        listingImageView.setBadgeImage(badge: nil)
        userNameLabel.text = nil
        listingTitleLabel.text = nil
        timeLastMessageLabel.text = nil
        pendingMessagesLabel.text = nil
        userImageView.image = nil
        statusIcon.image = nil
        statusLabel.text = nil
    }

    func setupCellWith(data: ConversationCellData, indexPath: IndexPath) {
        let tag = indexPath.hashValue

        userNameLabel.text = data.userName
        listingTitleLabel.text = data.listingName
        timeLastMessageLabel.text = data.messageDate?.relativeTimeString(false)
        pendingMessagesLabel.isHidden = data.unreadCount <= 0
        pendingMessagesLabel.text = "\(data.unreadCount)"

        listingImageView.setMainImage(mainImage: #imageLiteral(resourceName: "product_placeholder"))

        listingImageView.setBadgeImage(badge: data.amISelling ? #imageLiteral(resourceName: "ic_corner_selling") : #imageLiteral(resourceName: "ic_corner_buying"))

        setImageWith(url: data.listingImageUrl,
                     withPlaceholder: #imageLiteral(resourceName: "product_placeholder"),
                     intoImageView: listingImageView.mainView,
                     safeRecyclingTag: tag)

        if data.status != .userDeleted {
            setImageWith(url: data.userImageUrl,
                         withPlaceholder: data.userImagePlaceholder,
                         intoImageView: userImageView,
                         safeRecyclingTag: tag)
        }

        updateCellWith(status: data.status)

        setUserIsTyping(enabled: data.isTyping)
    }

    private func setImageWith(url: URL?,
                              withPlaceholder placeholder: UIImage?,
                              intoImageView imageView: UIImageView,
                              safeRecyclingTag: Int) {
        guard let url = url else { return }
        imageView.lg_setImageWithURL(url, placeholderImage: placeholder) {
            [weak self] (result, url) in
            // tag check to prevent wrong image placement cos' of recycling
            if let image = result.value?.image, self?.tag == safeRecyclingTag {
                imageView.image = image
            }
        }
    }

    private func updateCellWith(status: ConversationCellStatus) {

        guard status != .available else {
            textStackContainer.removeArrangedSubview(statusStackContainer)
            textStackContainer.addArrangedSubview(timeLastMessageLabel)
            timeLastMessageLabel.isHidden = false
            return
        }

        textStackContainer.removeArrangedSubview(timeLastMessageLabel)
        textStackContainer.addArrangedSubview(statusStackContainer)
        timeLastMessageLabel.isHidden = true

        if status == .userDeleted {
            userNameLabel.text = R.Strings.chatListAccountDeletedUsername
            listingTitleLabel.text = nil
            userImageView.image = #imageLiteral(resourceName: "user_placeholder")
        }

        statusLabel.text = status.message
        statusIcon.image = status.icon
    }

    private func setUserIsTyping(enabled: Bool) {
        if enabled {
            textStackContainer.removeArrangedSubview(timeLastMessageLabel)
            textStackContainer.addArrangedSubview(userIsTypingAnimationViewContainer)
            userIsTypingAnimationView.play()
            timeLastMessageLabel.isHidden = true
        } else {
            textStackContainer.removeArrangedSubview(userIsTypingAnimationViewContainer)
            textStackContainer.addArrangedSubview(timeLastMessageLabel)
            userIsTypingAnimationView.stop()
            timeLastMessageLabel.isHidden = false
        }
    }
}
