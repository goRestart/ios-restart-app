//
//  RelationInfoView.swift
//  LetGo
//
//  Created by Dídac on 17/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

public enum ChatInfoViewStatus: Int {

    case forbidden
    case blocked
    case blockedBy
    case productDeleted
    case productSold
    case userPendingDelete
    case userDeleted
    case available

    func infoText(otherUserName userName: String?) -> String {
        switch self {
        case .forbidden:
            if let userName = userName {
                return LGLocalizedString.accountPendingModerationWName(userName)
            } else {
                return LGLocalizedString.accountPendingModeration
            }
        case .blocked:
            if let userName = userName {
                return LGLocalizedString.chatBlockedByMeLabelWName(userName)
            } else {
                return LGLocalizedString.chatBlockedByMeLabel
            }
        case .blockedBy:
            return LGLocalizedString.chatBlockedByOtherLabel
        case .productDeleted:
            return LGLocalizedString.commonProductNotAvailable
        case .productSold:
            return LGLocalizedString.chatProductSoldLabel
        case .userPendingDelete, .userDeleted:
            if let userName = userName {
                return LGLocalizedString.chatAccountDeletedWName(userName)
            } else {
                return LGLocalizedString.chatAccountDeletedWoName
            }
        case .available:
            return ""
        }
    }


    var infoTextColor: UIColor {
        return UIColor.white
    }

    var bgColor: UIColor {
        switch self {
        case .forbidden, .userDeleted, .userPendingDelete, .blockedBy, .productDeleted:
            return UIColor.black
        case .blocked:
            return UIColor.primaryColor
        case .productSold:
            return UIColor.soldColor
        case .available:
            return UIColor.clear
        }
    }

    var iconImage: UIImage {
        switch self {
        case .forbidden:
            return UIImage(named: "ic_pending_moderation") ?? UIImage()
        case .userDeleted, .userPendingDelete:
            return UIImage(named: "ic_alert_yellow_white_inside") ?? UIImage()
        case .blocked:
            return UIImage(named: "ic_blocked_white") ?? UIImage()
        case .blockedBy:
            return UIImage(named: "ic_blocked_white_line") ?? UIImage()
        case .productDeleted:
            return UIImage(named: "ic_alert_yellow_white_inside") ?? UIImage()
        case .productSold:
            return UIImage(named: "ic_sold_white") ?? UIImage()
        case .available:
            return UIImage()
        }
    }

    var isHidden: Bool {
        switch self {
        case .forbidden, .blocked, .blockedBy, .productDeleted, .productSold, .userDeleted, .userPendingDelete:
            return false
        case .available:
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

    open static func relationInfoView() -> RelationInfoView {
        guard let view =  Bundle.main.loadNibNamed("RelationInfoView", owner: self, options: nil)?
            .first as? RelationInfoView else { return RelationInfoView() }
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
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
        containerView.backgroundColor = UIColor.clear
        chatInfoLabel.font = UIFont.smallBodyFont
        chatInfoLabel.textAlignment = .left
        chatInfoIcon.contentMode = .scaleAspectFill
        chatInfoIcon.clipsToBounds = true
    }
}
