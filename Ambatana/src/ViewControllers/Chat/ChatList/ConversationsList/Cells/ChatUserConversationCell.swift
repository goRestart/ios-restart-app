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
        static let assistantInfoLabelHeight: CGFloat = 20
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

    private let proUserNameStackContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.spacing = 8
        return stackView
    }()

    private let assistantInfoStackContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.spacing = 8
        return stackView
    }()

    private let assistantInfoLabel: UIRoundedLabelWithPadding = {
        let label = UIRoundedLabelWithPadding()
        label.font = .systemMediumFont(size: 13)
        label.textColor = .primaryColor
        label.textAlignment = .center
        label.text = R.Strings.chatConversationsListLetgoAssistantTag
        label.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.1)
        label.padding = UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
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
    private let userIsTypingAnimationViewContainer = UIView()

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

        statusStackContainer.addArrangedSubview(statusIcon)
        statusStackContainer.addArrangedSubview(statusLabel)

        proUserNameStackContainer.addArrangedSubview(userNameLabel)
        proUserNameStackContainer.addArrangedSubview(proUserTagView)

        assistantInfoStackContainer.addArrangedSubview(userNameLabel)
        assistantInfoStackContainer.addArrangedSubview(assistantInfoLabel)

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
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        listingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        assistantInfoLabel.translatesAutoresizingMaskIntoConstraints = false

        listingImageView.layout().widthProportionalToHeight()
        pendingMessagesLabel.layout().height(Layout.pendingMessagesBadgeHeight)
        statusIcon.layout().height(Layout.statusIconHeight).widthProportionalToHeight()
        listingTitleLabel.layout().height(Layout.listingTitleLabelHeight)
        assistantInfoLabel.layout().height(Layout.assistantInfoLabelHeight)

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
        assistantInfoLabel.set(accessibilityId: .assistantConversationCellInfoLabel)
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

        updateCellWith(status: data.status)
        setUserIsTyping(enabled: data.isTyping)
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

    private func updateCellWith(status: ConversationCellStatus) {
        let lastStackPosition = textStackContainer.arrangedSubviews.count-1
        guard status != .available else {
            textStackContainer.insertArrangedSubview(timeLastMessageLabel, at: lastStackPosition)
            textStackContainer.removeArrangedSubview(statusStackContainer)
            statusStackContainer.removeFromSuperview()
            return
        }

        textStackContainer.insertArrangedSubview(statusStackContainer, at: lastStackPosition)
        textStackContainer.removeArrangedSubview(timeLastMessageLabel)
        timeLastMessageLabel.removeFromSuperview()

        if status == .userDeleted {
            userNameLabel.text = R.Strings.chatListAccountDeletedUsername
            listingTitleLabel.text = nil
            userImageView.image = R.Asset.IconsButtons.userPlaceholder.image
        }

        statusLabel.text = status.message
        statusIcon.image = status.icon
    }

    private func setUserIsTyping(enabled: Bool) {
        let lastStackPosition = textStackContainer.arrangedSubviews.count-1
        let lastStackContent = textStackContainer.arrangedSubviews[lastStackPosition]
        if enabled {
            textStackContainer.removeArrangedSubview(lastStackContent)
            textStackContainer.insertArrangedSubview(userIsTypingAnimationViewContainer, at: lastStackPosition)
            userIsTypingAnimationView.play()
            timeLastMessageLabel.removeFromSuperview()
        } else {
            textStackContainer.removeArrangedSubview(userIsTypingAnimationViewContainer)
            textStackContainer.insertArrangedSubview(lastStackContent, at: lastStackPosition)
            userIsTypingAnimationView.stop()
            userIsTypingAnimationViewContainer.removeFromSuperview()
        }
    }

    private func updateCellFor(userType: UserType?) {
        guard let type = userType else {
            textStackContainer.removeArrangedSubview(assistantInfoStackContainer)
            textStackContainer.removeArrangedSubview(proUserNameStackContainer)
            textStackContainer.insertArrangedSubview(userNameLabel, at: 0)
            proUserTagView.isHidden = true
            assistantInfoLabel.isHidden = true
            return
        }

        switch type {
        case .user:
            textStackContainer.removeArrangedSubview(assistantInfoStackContainer)
            textStackContainer.removeArrangedSubview(proUserNameStackContainer)
            textStackContainer.insertArrangedSubview(userNameLabel, at: 0)
            proUserTagView.isHidden = true
            assistantInfoLabel.isHidden = true
        case .pro:
            textStackContainer.removeArrangedSubview(userNameLabel)
            textStackContainer.removeArrangedSubview(assistantInfoStackContainer)
            proUserNameStackContainer.insertArrangedSubview(userNameLabel, at: 0)
            textStackContainer.insertArrangedSubview(proUserNameStackContainer, at: 0)
            proUserTagView.isHidden = false
            assistantInfoLabel.isHidden = true
        case .dummy:
            textStackContainer.removeArrangedSubview(userNameLabel)
            textStackContainer.removeArrangedSubview(proUserNameStackContainer)
            assistantInfoStackContainer.insertArrangedSubview(userNameLabel, at: 0)
            textStackContainer.insertArrangedSubview(assistantInfoStackContainer, at: 0)
            proUserTagView.isHidden = true
            assistantInfoLabel.isHidden = false
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
