import LGCoreKit
import UIKit
import Lottie
import LGComponents

enum ConversationCellStatus {
    case available
    case forbidden
    case listingSold
    case listingGivenAway
    case listingDeleted
    case userPendingDelete
    case userDeleted
    case userBlocked
    case blockedByUser

    var icon: UIImage? {
        switch self {
        case .forbidden:
            return #imageLiteral(resourceName: "ic_pending_moderation")
        case .listingSold, .listingGivenAway:
            return #imageLiteral(resourceName: "ic_dollar_sold")
        case .listingDeleted, .userPendingDelete, .userDeleted:
            return #imageLiteral(resourceName: "ic_alert_yellow_white_inside")
        case .userBlocked, .blockedByUser:
            return #imageLiteral(resourceName: "ic_blocked")
        case .available:
            return nil
        }
    }

    var message: String? {
        switch self {
        case .forbidden:
            return R.Strings.accountPendingModeration
        case .listingSold:
            return R.Strings.commonProductSold
        case .listingGivenAway:
            return R.Strings.commonProductGivenAway
        case .listingDeleted:
            return R.Strings.commonProductNotAvailable
        case .userPendingDelete:
            return R.Strings.chatListAccountDeleted
        case .userDeleted:
            return R.Strings.chatListAccountDeleted
        case .userBlocked:
            return R.Strings.chatListBlockedUserLabel
        case .blockedByUser:
            return R.Strings.chatBlockedByOtherLabel
        case .available:
            return nil
        }
    }
}

struct ConversationCellData {
    let status: ConversationCellStatus
    let conversationId: String?
    let userId: String?
    let userName: String
    let userImageUrl: URL?
    let userImagePlaceholder: UIImage?
    let userType: UserType?
    let amISelling: Bool
    let listingId: String?
    let listingName: String
    let listingImageUrl: URL?
    let unreadCount: Int
    let messageDate: Date?
    let isTyping: Bool
}

class ConversationCell: UITableViewCell, ReusableCell {

    static var reusableID = "ConversationCell"

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var listingLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var separationStatusImageToTimeLabel: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    private let userIsTypingAnimationView: LOTAnimationView = {
        let view = LOTAnimationView(name: "lottie_chat_typing_animation")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.loopAnimation = true
        return view
    }()
    private let userIsTypingAnimationViewContainer = UIView()

    static let defaultHeight: CGFloat = 76
    private static let statusImageDefaultMargin: CGFloat = 4

    private var lines: [CALayer] = []


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        resetUI()
        setAccessibilityIds()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(contentView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }


    // MARK: - Overrides

    override func setSelected(_ selected: Bool, animated: Bool) {
        if (selected && !isEditing) {
            super.setSelected(false, animated: animated)
        } else {
            super.setSelected(selected, animated: animated)
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if (editing) {
            let bgView = UIView()
            selectedBackgroundView = bgView
        } else {
            selectedBackgroundView = nil
        }
        super.setEditing(editing, animated: animated)
        tintColor = UIColor.primaryColor
    }


    // MARK: - Public methods

    func setupCellWithData(_ data: ConversationCellData, indexPath: IndexPath) {
        let tag = (indexPath as NSIndexPath).hash

        // thumbnail
        if let thumbURL = data.listingImageUrl {
            thumbnailImageView.lg_setImageWithURL(thumbURL) {
                [weak self] (result, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if let image = result.value?.image, self?.tag == tag {
                    self?.thumbnailImageView.image = image
                }
            }
        }
        avatarImageView.image = data.userImagePlaceholder
        if let avatarURL = data.userImageUrl {
            avatarImageView.lg_setImageWithURL(avatarURL, placeholderImage: data.userImagePlaceholder) {
                [weak self] (result, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if let image = result.value?.image, self?.tag == tag {
                    self?.avatarImageView.image = image
                }
            }
        }

        listingLabel.text = data.listingName
        userLabel.text = data.userName

        if data.unreadCount > 0 {
            timeLabel.font = UIFont.conversationTimeUnreadFont
            listingLabel.font = UIFont.conversationProductUnreadFont
            userLabel.font = UIFont.conversationUserNameUnreadFont
        } else {
            timeLabel.font = UIFont.conversationTimeFont
            listingLabel.font = UIFont.conversationProductFont
            userLabel.font = UIFont.conversationUserNameFont
        }

        let statusText = data.status == .available ? data.messageDate?.relativeTimeString(false) ?? "" : data.status.message
        setInfo(text: statusText, icon: data.status.icon)

        if data.status == .userDeleted {
            userLabel.text = R.Strings.chatListAccountDeletedUsername
            listingLabel.text = nil
            avatarImageView.image = UIImage(named: "user_placeholder")
        }

        let badge: String? = data.unreadCount > 0 ? String(data.unreadCount) : nil
        badgeLabel.text = badge
        badgeView.isHidden = (badge == nil)
        
        set(accessibilityId: .conversationCellContainer(conversationId: data.conversationId))
        userLabel.set(accessibilityId: .conversationCellUserLabel(interlocutorId: data.userId))
        listingLabel.set(accessibilityId: .conversationCellListingLabel(listingId: data.listingId))
        
        setUserIsTyping(enabled: data.isTyping)
    }


    // MARK: - Private methods

    private func setupUI() {
        thumbnailImageView.cornerRadius = LGUIKitConstants.smallCornerRadius
        avatarImageView.setRoundedCorners()
        avatarImageView.clipsToBounds = true
        listingLabel.font = UIFont.conversationProductFont
        userLabel.font = UIFont.conversationUserNameFont
        timeLabel.font = UIFont.conversationTimeFont

        listingLabel.textColor = UIColor.darkGrayText
        userLabel.textColor = UIColor.blackText
        timeLabel.textColor = UIColor.darkGrayText
        thumbnailImageView.backgroundColor = UIColor.placeholderBackgroundColor()
        badgeView.setRoundedCorners()
        
        userIsTypingAnimationViewContainer.translatesAutoresizingMaskIntoConstraints = false
        userIsTypingAnimationViewContainer.backgroundColor = UIColor.grayBackground
        userIsTypingAnimationViewContainer.addSubview(userIsTypingAnimationView)
        contentView.addSubview(userIsTypingAnimationViewContainer)
        userIsTypingAnimationViewContainer.layout(with: thumbnailImageView).bottom()
        userIsTypingAnimationViewContainer.layout(with: userLabel).leading()
        userIsTypingAnimationViewContainer.layout()
            .width(40)
            .height(24)
        userIsTypingAnimationViewContainer.layoutIfNeeded()
        userIsTypingAnimationViewContainer.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        userIsTypingAnimationViewContainer.clipsToBounds = true
        
        userIsTypingAnimationView.layout(with: userIsTypingAnimationViewContainer)
            .fill()
    }

    private func resetUI() {
        thumbnailImageView.image = UIImage(named: "product_placeholder")
        avatarImageView.image = nil
        listingLabel.text = ""
        userLabel.text = ""
        timeLabel.text = ""
        badgeView.isHidden = true
        badgeView.backgroundColor = UIColor.primaryColor
        badgeLabel.text = ""
        badgeLabel.font = UIFont.conversationBadgeFont
        userIsTypingAnimationView.stop()
    }

    private func setInfo(text: String?, icon: UIImage?) {
        timeLabel.text = text
        if let icon = icon {
            statusImageView.image = icon
            statusImageView.isHidden = false
            separationStatusImageToTimeLabel.constant = ConversationCell.statusImageDefaultMargin
        } else {
            statusImageView.isHidden = true
            separationStatusImageToTimeLabel.constant = -statusImageView.frame.width
        }
    }
    
    private func setUserIsTyping(enabled: Bool) {
        if enabled {
            listingLabel.animateTo(alpha: 0)
            timeLabel.animateTo(alpha: 0)
            statusImageView.animateTo(alpha: 0)
            userIsTypingAnimationView.play()
            userIsTypingAnimationViewContainer.animateTo(alpha: 1)
        } else {
            userIsTypingAnimationViewContainer.animateTo(alpha: 0)
            userIsTypingAnimationView.stop()
            listingLabel.animateTo(alpha: 1)
            timeLabel.animateTo(alpha: 1)
            statusImageView.animateTo(alpha: 1)
        }
    }
}

extension ConversationCell {
    func setAccessibilityIds() {
        timeLabel.set(accessibilityId: .conversationCellTimeLabel)
        badgeLabel.set(accessibilityId: .conversationCellBadgeLabel)
        thumbnailImageView.set(accessibilityId: .conversationCellThumbnailImageView)
        avatarImageView.set(accessibilityId: .conversationCellAvatarImageView)
        statusImageView.set(accessibilityId: .conversationCellStatusImageView)
    }
}
