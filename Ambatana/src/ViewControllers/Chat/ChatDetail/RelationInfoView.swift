import UIKit
import LGComponents

enum ChatInfoViewStatus: Int {

    case forbidden
    case blocked
    case blockedBy
    case listingDeleted
    case listingSold
    case listingGivenAway
    case userPendingDelete
    case userDeleted
    case available
    case inactiveConversation

    func infoText(otherUserName userName: String?) -> String {
        switch self {
        case .forbidden:
            if let userName = userName {
                return R.Strings.accountPendingModerationWName(userName)
            } else {
                return R.Strings.accountPendingModeration
            }
        case .blocked:
            if let userName = userName {
                return R.Strings.chatBlockedByMeLabelWName(userName)
            } else {
                return R.Strings.chatBlockedByMeLabel
            }
        case .blockedBy:
            return R.Strings.chatBlockedByOtherLabel
        case .listingSold:
            return R.Strings.chatProductSoldLabel
        case .listingGivenAway:
            return R.Strings.chatProductGivenAwayLabel
        case .userPendingDelete, .userDeleted:
            if let userName = userName {
                return R.Strings.chatAccountDeletedWName(userName)
            } else {
                return R.Strings.chatAccountDeletedWoName
            }
        case .available, .listingDeleted:
            return ""
        case .inactiveConversation:
            return R.Strings.chatInactiveConversationRelationExplanation
        }
    }


    var infoTextColor: UIColor {
        return UIColor.white
    }

    var bgColor: UIColor {
        switch self {
        case .forbidden, .userDeleted, .userPendingDelete, .blockedBy, .inactiveConversation:
            return .lgBlack
        case .blocked:
            return .primaryColor
        case .listingSold, .listingGivenAway:
            return .soldColor
        case .available, .listingDeleted:
            return .clear
        }
    }

    var iconImage: UIImage {
        switch self {
        case .forbidden:
            return R.Asset.IconsButtons.icPendingModeration.image
        case .userDeleted, .userPendingDelete:
            return R.Asset.BackgroundsAndImages.icAlertYellowWhiteInside.image
        case .blocked:
            return R.Asset.BackgroundsAndImages.icBlockedWhite.image
        case .blockedBy:
            return R.Asset.BackgroundsAndImages.icBlockedWhiteLine.image
        case .inactiveConversation:
            return R.Asset.BackgroundsAndImages.icAlertYellowWhiteInside.image
        case .listingSold, .listingGivenAway:
            return R.Asset.BackgroundsAndImages.icSoldWhite.image
        case .available, .listingDeleted:
            return UIImage()
        }
    }

    var isHidden: Bool {
        switch self {
        case .forbidden, .blocked, .blockedBy, .listingSold, .listingGivenAway, .userDeleted, .userPendingDelete, .inactiveConversation:
            return false
        case .available, .listingDeleted:
            return true
        }
    }

    var heightValue: CGFloat {
        return isHidden ? 0 : RelationInfoView.defaultHeight
    }
}

class RelationInfoView: UIView {

    static let defaultHeight: CGFloat = 28
    private static let visibleMaxHeight: CGFloat = 60

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chatInfoIcon: UIImageView!
    @IBOutlet weak var chatInfoLabel: UILabel!
    @IBOutlet weak var relationInfoViewMaxHeight: NSLayoutConstraint!

    static func relationInfoView() -> RelationInfoView {
        guard let view =  Bundle.main.loadNibNamed("RelationInfoView", owner: self, options: nil)?
            .first as? RelationInfoView else { return RelationInfoView() }
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupUIForStatus(_ status: ChatInfoViewStatus, otherUserName: String?) {
        setupBasicUI()

        // Status dependant setup
        isHidden = status.isHidden
        relationInfoViewMaxHeight.constant = status.isHidden ? 0 : RelationInfoView.visibleMaxHeight
        backgroundColor = status.bgColor
        chatInfoLabel.textColor = status.infoTextColor
        chatInfoLabel.text = status.infoText(otherUserName: otherUserName)
        chatInfoIcon.image = status.iconImage
    }

    func setupBasicUI() {
        // Non-Status dependant setup
        containerView.backgroundColor = .clear
        chatInfoLabel.font = UIFont.smallBodyFont
        chatInfoLabel.textAlignment = .left
        chatInfoIcon.contentMode = .scaleAspectFill
        chatInfoIcon.clipsToBounds = true
    }
}
