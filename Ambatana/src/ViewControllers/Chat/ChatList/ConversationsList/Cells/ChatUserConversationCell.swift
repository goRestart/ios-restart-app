import Foundation
import UIKit
import LGCoreKit
import Lottie
import LGComponents

final class ChatUserConversationCell: UITableViewCell, ReusableCell {

    struct Layout {
        static let listingImageViewHeight: CGFloat = 64
        static let userImageViewHeight: CGFloat = 40
        static let transactionBadgeHeight: CGFloat = 30
        static let pendingMessagesBadgeHeight: CGFloat = 18
        static let listingTitleLabelHeight: CGFloat = 18
        static let assistantInfoHeight: CGFloat = 18
        static let statusIconHeight: CGFloat = 12
        static let userTypingAnimationWidth: CGFloat = 40
        static let userTypingAnimationHeight: CGFloat = 24
        static let assistantBadgeMargin: CGFloat = 2
    }

    private let listingImageView: ChatAvatarView = {
        let imageView = ChatAvatarView(mainCornerRadius: .custom(radius: 4),
                                       badgeStyle: .topLeft(height: Layout.transactionBadgeHeight),
                                       shareBounds: true)
        return imageView
    }()

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = Layout.userImageViewHeight/2
        return imageView
    }()

    private let mainStackContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8)
        stackView.spacing = 0
        return stackView
    }()

    private let textsContainerView = UIView()
    private let userImageContainerView = UIView()

    private let assistantInfoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.1)
        view.cornerRadius = Layout.assistantInfoHeight/2
        return view
    }()

    private let assistantInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemMediumFont(size: 11)
        label.textColor = .primaryColor
        label.textAlignment = .center
        label.text = R.Strings.chatConversationsListLetgoAssistantTag
        return label
    }()

    private let assistantInfoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.Asset.IconsButtons.icAssistantTag.image
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 17)
        label.textColor = .blackText
        label.textAlignment = .left
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let listingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(size: 15)
        label.textColor = .darkGrayText
        label.textAlignment = .left
        return label
    }()

    private let timeLastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemLightFont(size: 13)
        label.textColor = .darkGrayText
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
        label.textColor = .darkGrayText
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
    private let userIsTypingAnimationViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .grayBackground
        return view
    }()

    private let proUserTagView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.Monetization.proTag.image
        imageView.contentMode = .scaleAspectFit
        imageView.applyShadow(withOpacity: 0.5, radius: 2)
        return imageView
    }()

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
        selectionStyle = .none
        mainStackContainer.addArrangedSubviews([listingImageView, textsContainerView, userImageContainerView])
    }

    func setupConstraints() {

        // left arranged subview
        listingImageView.translatesAutoresizingMaskIntoConstraints = false
        listingImageView.layout().height(Layout.listingImageViewHeight).widthProportionalToHeight()

        statusIcon.layout().height(Layout.statusIconHeight).widthProportionalToHeight()
        listingTitleLabel.layout().height(Layout.listingTitleLabelHeight)
        assistantInfoContainerView.layout().height(Layout.assistantInfoHeight)

        contentView.addSubviewForAutoLayout(mainStackContainer)

        let cellConstraints = [
            mainStackContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStackContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(cellConstraints)

        assistantInfoContainerView.addSubviewsForAutoLayout([assistantInfoIcon, assistantInfoLabel])

        let assistantInfoConstraints = [
            assistantInfoIcon.leadingAnchor.constraint(equalTo: assistantInfoContainerView.leadingAnchor,
                                                       constant: Layout.assistantBadgeMargin),
            assistantInfoIcon.topAnchor.constraint(equalTo: assistantInfoContainerView.topAnchor,
                                                   constant: Layout.assistantBadgeMargin),
            assistantInfoIcon.bottomAnchor.constraint(equalTo: assistantInfoContainerView.bottomAnchor,
                                                      constant: -Layout.assistantBadgeMargin),
            assistantInfoIcon.trailingAnchor.constraint(equalTo: assistantInfoLabel.leadingAnchor,
                                                        constant: -Metrics.veryShortMargin),
            assistantInfoLabel.topAnchor.constraint(equalTo: assistantInfoContainerView.topAnchor),
            assistantInfoLabel.bottomAnchor.constraint(equalTo: assistantInfoContainerView.bottomAnchor),
            assistantInfoLabel.trailingAnchor.constraint(equalTo: assistantInfoContainerView.trailingAnchor,
                                                         constant: -Metrics.shortMargin)
        ]

        NSLayoutConstraint.activate(assistantInfoConstraints)

        textsContainerView.addSubviewsForAutoLayout([userNameLabel,
                                                     proUserTagView,
                                                     listingTitleLabel,
                                                     assistantInfoContainerView,
                                                     timeLastMessageLabel,
                                                     statusIcon,
                                                     statusLabel,
                                                     userIsTypingAnimationViewContainer])

        let textsContainerViewConstraints = [
            userNameLabel.topAnchor.constraint(equalTo: textsContainerView.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: textsContainerView.leadingAnchor, constant: Metrics.shortMargin),
            proUserTagView.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor, constant: Metrics.margin),
            proUserTagView.trailingAnchor.constraint(lessThanOrEqualTo: textsContainerView.trailingAnchor),
            proUserTagView.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor),
            assistantInfoContainerView.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor, constant: Metrics.margin),
            assistantInfoContainerView.trailingAnchor.constraint(lessThanOrEqualTo: textsContainerView.trailingAnchor, constant: -Metrics.margin),
            assistantInfoContainerView.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor),

            listingTitleLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor,
                                                   constant: Metrics.veryShortMargin),
            listingTitleLabel.leadingAnchor.constraint(equalTo: textsContainerView.leadingAnchor, constant: Metrics.shortMargin),
            listingTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: textsContainerView.trailingAnchor),

            timeLastMessageLabel.topAnchor.constraint(equalTo: listingTitleLabel.bottomAnchor,
                                                      constant: Metrics.veryShortMargin),
            timeLastMessageLabel.leadingAnchor.constraint(equalTo: textsContainerView.leadingAnchor, constant: Metrics.shortMargin),
            timeLastMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: textsContainerView.trailingAnchor),
            timeLastMessageLabel.bottomAnchor.constraint(equalTo: textsContainerView.bottomAnchor, constant: Metrics.veryShortMargin),

            userIsTypingAnimationViewContainer.leadingAnchor.constraint(equalTo: textsContainerView.leadingAnchor, constant: Metrics.shortMargin),
            userIsTypingAnimationViewContainer.trailingAnchor.constraint(lessThanOrEqualTo: textsContainerView.trailingAnchor),
            userIsTypingAnimationViewContainer.centerYAnchor.constraint(equalTo: timeLastMessageLabel.centerYAnchor),

            statusIcon.leadingAnchor.constraint(equalTo: textsContainerView.leadingAnchor, constant: Metrics.shortMargin),
            statusIcon.centerYAnchor.constraint(equalTo: timeLastMessageLabel.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: Metrics.veryShortMargin),
            statusLabel.centerYAnchor.constraint(equalTo: statusIcon.centerYAnchor),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: textsContainerView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(textsContainerViewConstraints)

        userIsTypingAnimationViewContainer.addSubview(userIsTypingAnimationView)
        userIsTypingAnimationViewContainer.layout()
            .width(Layout.userTypingAnimationWidth)
            .height(Layout.userTypingAnimationHeight)
        userIsTypingAnimationViewContainer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        userIsTypingAnimationView.layout(with: userIsTypingAnimationViewContainer)
            .fill()

        userImageContainerView.addSubviewsForAutoLayout([userImageView, pendingMessagesLabel])
        userImageView.layout().height(Layout.userImageViewHeight).width(Layout.userImageViewHeight)
        pendingMessagesLabel.layout().height(Layout.pendingMessagesBadgeHeight)

        let rightContainerConstraints = [
            userImageView.leadingAnchor.constraint(equalTo: userImageContainerView.leadingAnchor),
            userImageView.topAnchor.constraint(equalTo: userImageContainerView.topAnchor),
            userImageView.trailingAnchor.constraint(equalTo: userImageContainerView.trailingAnchor),
            pendingMessagesLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: -Metrics.shortMargin),
            pendingMessagesLabel.centerXAnchor.constraint(equalTo: userImageContainerView.centerXAnchor),
            pendingMessagesLabel.bottomAnchor.constraint(equalTo: userImageContainerView.bottomAnchor)
        ]

        NSLayoutConstraint.activate(rightContainerConstraints)
    }

    func setAccessibilityIds() {
        timeLastMessageLabel.set(accessibilityId: .conversationCellTimeLabel)
        pendingMessagesLabel.set(accessibilityId: .conversationCellBadgeLabel)
        listingImageView.set(accessibilityId: .conversationCellThumbnailImageView)
        userImageView.set(accessibilityId: .conversationCellAvatarImageView)
        statusIcon.set(accessibilityId: .conversationCellStatusImageView)
        assistantInfoContainerView.set(accessibilityId: .assistantConversationCellInfoLabel)
    }

    func resetUI() {
        contentView.backgroundColor = .white
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
        tag = indexPath.hashValue
        userNameLabel.text = data.userName
        listingTitleLabel.text = data.listingName
        timeLastMessageLabel.text = data.messageDate?.relativeTimeString(false)
        pendingMessagesLabel.isHidden = data.unreadCount <= 0
        pendingMessagesLabel.text = "\(data.unreadCount)"

        listingImageView.setMainImage(mainImage: R.Asset.IconsButtons.productPlaceholder.image)

        listingImageView.setBadgeImage(badge: data.badge)
        contentView.backgroundColor = data.backgroundColor

        setImageWith(url: data.listingImageUrl,
                     intoImageView: listingImageView.mainView,
                     safeRecyclingTag: tag)

        if data.status != .userDeleted {
            userImageView.image = data.userImagePlaceholder
            setImageWith(url: data.userImageUrl,
                         intoImageView: userImageView,
                         safeRecyclingTag: tag)
        }

        updateCellWith(status: data.status, userIsTyping: data.isTyping)
        updateCellFor(userType: data.userType)
    }

    private func setImageWith(url: URL?,
                              intoImageView imageView: UIImageView,
                              safeRecyclingTag: Int) {
        guard let url = url else { return }
        imageView.lg_setImageWithURL(url) {
            [weak self] (result, url) in
            // tag check to prevent wrong image placement cos' of recycling
            if let image = result.value?.image, self?.tag == safeRecyclingTag {
                imageView.image = image
            }
        }
    }

    private func updateCellWith(status: ConversationCellStatus, userIsTyping: Bool) {
        guard !userIsTyping else {
            timeLastMessageLabel.isHidden = true
            statusIcon.isHidden = true
            statusLabel.isHidden = true
            userIsTypingAnimationViewContainer.isHidden = false
            userIsTypingAnimationView.play()
            return
        }
        userIsTypingAnimationViewContainer.isHidden = true
        userIsTypingAnimationView.stop()

        guard status != .available else {
            timeLastMessageLabel.isHidden = false
            statusIcon.isHidden = true
            statusLabel.isHidden = true
            return
        }

        timeLastMessageLabel.isHidden = true
        statusIcon.isHidden = false
        statusLabel.isHidden = false

        if status == .userDeleted {
            userNameLabel.text = R.Strings.chatListAccountDeletedUsername
            listingTitleLabel.text = nil
            userImageView.image = R.Asset.IconsButtons.userPlaceholder.image
        }

        statusLabel.text = status.message
        statusIcon.image = status.icon
    }

    private func updateCellFor(userType: UserType?) {
        guard let type = userType else {
            proUserTagView.isHidden = true
            assistantInfoContainerView.isHidden = true
            assistantInfoContainerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            userNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            return
        }

        switch type {
        case .user:
            proUserTagView.isHidden = true
            assistantInfoContainerView.isHidden = true
            assistantInfoContainerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            userNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        case .pro:
            proUserTagView.isHidden = false
            assistantInfoContainerView.isHidden = true
            assistantInfoContainerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        case .dummy:
            proUserTagView.isHidden = true
            assistantInfoContainerView.isHidden = false
            assistantInfoContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            userNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
}

extension ConversationCellData {
    var isDummy: Bool {
        return userType?.isDummy ?? false
    }
    var badge: UIImage? {
        guard !isDummy else { return nil }
        return amISelling ? R.Asset.Chat.icCornerSelling.image : R.Asset.Chat.icCornerBuying.image
    }

    var backgroundColor: UIColor {
        return isDummy ? .assistantConversationCellBgColor : .white
    }
}

