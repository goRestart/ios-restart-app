import Foundation
import LGCoreKit
import LGComponents

final class ChatAssistantConversationCell: UITableViewCell, ReusableCell {

    static let badgeImage: UIImage = #imageLiteral(resourceName: "ic_assistant_tag")

    struct Layout {
        static let avatarHeight: CGFloat = 60
        static let assistantBadgeHeight: CGFloat = 24
        static let assistantInfoLabelHeight: CGFloat = 18
        static let pendingMessagesBadgeHeight: CGFloat = 18
        static let rightContainerWidth: CGFloat = 38
    }
    
    private let avatarView: ChatAvatarView = ChatAvatarView(mainCornerRadius: .round,
                                                            badgeStyle: .bottomRight(height: Layout.assistantBadgeHeight),
                                                            shareBounds: false)

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
        stackView.alignment = UIStackViewAlignment.leading
        stackView.distribution = .equalSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10)
        stackView.spacing = 5
        return stackView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 17)
        label.textColor = .blackText
        label.textAlignment = .left
        return label
    }()

    private let assistantInfoLabel: UIRoundedLabelWithPadding = {
        let label = UIRoundedLabelWithPadding()
        label.font = .systemMediumFont(size: 13)
        label.textColor = .primaryColor
        label.textAlignment = .center
        label.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.1)
        label.padding = UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
        return label
    }()

    private let timeLastMessageLabel: UILabel = {
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
        contentView.backgroundColor = UIColor.assistantConversationCellBgColor
        layoutMargins = .zero
        selectionStyle = .none

        textStackContainer.addArrangedSubview(userNameLabel)
        textStackContainer.addArrangedSubview(assistantInfoLabel)
        textStackContainer.addArrangedSubview(timeLastMessageLabel)

        mainStackContainer.addArrangedSubview(avatarView)
        mainStackContainer.addArrangedSubview(textStackContainer)

        let rightContainerView = UIView()
        rightContainerView.addSubviewForAutoLayout(pendingMessagesLabel)

        let rightContainerConstraints = [
            rightContainerView.widthAnchor.constraint(equalToConstant: Layout.rightContainerWidth),
            pendingMessagesLabel.centerXAnchor.constraint(equalTo: rightContainerView.centerXAnchor),
            pendingMessagesLabel.centerYAnchor.constraint(equalTo: rightContainerView.centerYAnchor)
        ]

        NSLayoutConstraint.activate(rightContainerConstraints)

        mainStackContainer.addArrangedSubview(rightContainerView)
    }

    func setupConstraints() {

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        pendingMessagesLabel.translatesAutoresizingMaskIntoConstraints = false

        avatarView.layout().height(Layout.avatarHeight).widthProportionalToHeight()
        pendingMessagesLabel.layout().height(Layout.pendingMessagesBadgeHeight)


        contentView.addSubviewForAutoLayout(mainStackContainer)

        let cellConstraints = [
            mainStackContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStackContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(cellConstraints)
    }

    func setAccessibilityIds() {
        userNameLabel.set(accessibilityId: .assistantConversationCellNameLabel)
        timeLastMessageLabel.set(accessibilityId: .assistantConversationCellTimeLabel)
        pendingMessagesLabel.set(accessibilityId: .assistantConversationCellBadgeLabel)
        assistantInfoLabel.set(accessibilityId: .assistantConversationCellInfoLabel)
        avatarView.set(accessibilityId: .assistantConversationCellAvatarImageView)
    }

    func resetUI() {
        avatarView.setMainImage(mainImage: nil)
        avatarView.setBadgeImage(badge: nil)
        userNameLabel.text = nil
        assistantInfoLabel.text = nil
        timeLastMessageLabel.text = nil
        pendingMessagesLabel.text = nil
    }

    func setupCellWith(data: ConversationCellData, indexPath: IndexPath) {
        let tag = indexPath.hashValue

        userNameLabel.text = data.userName
        assistantInfoLabel.text = R.Strings.chatConversationsListLetgoAssistantTag
        timeLastMessageLabel.text = data.messageDate?.relativeTimeString(false)
        pendingMessagesLabel.isHidden = data.unreadCount <= 0
        pendingMessagesLabel.text = "\(data.unreadCount)"

        avatarView.setMainImage(mainImage: data.userImagePlaceholder)
        avatarView.setBadgeImage(badge: ChatAssistantConversationCell.badgeImage)

        if let avatarURL = data.userImageUrl {
            avatarView.lg_setImageWithURL(avatarURL, placeholderImage: data.userImagePlaceholder) {
                [weak self] (result, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if let image = result.value?.image, self?.tag == tag {
                    self?.avatarView.setMainImage(mainImage: image)
                }
            }
        }
    }
}

