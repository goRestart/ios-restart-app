//
//  RelationInfoView.swift
//  LetGo
//
//  Created by Dídac on 17/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

public enum ChatInfoViewStatus: Int {

    case Forbidden
    case Blocked
    case BlockedBy
    case ProductInactive
    case ProductSold
    case Available

    var infoText: String {
        switch self {
        case .Forbidden:
            return LGLocalizedString.accountDeactivated
        case .Blocked:
            return LGLocalizedString.chatBlockedByMeLabel
        case .BlockedBy:
            return LGLocalizedString.chatBlockedByOtherLabel
        case .ProductInactive:
            return LGLocalizedString.chatProductInactiveLabel
        case .ProductSold:
            return LGLocalizedString.chatProductSoldLabel
        case .Available:
            return ""
        }
    }

    var infoTextColor: UIColor {
        return UIColor.whiteColor()
    }

    var bgColor: UIColor {
        switch self {
        case .Forbidden:
            return StyleHelper.chatInfoBackgrounColorAccountDeactivated
        case .Blocked:
            return StyleHelper.chatInfoBackgrounColorBlocked
        case .BlockedBy:
            return StyleHelper.chatInfoBackgrounColorBlockedBy
        case .ProductInactive:
            return StyleHelper.chatInfoBackgroundColorProductInactive
        case .ProductSold:
            return StyleHelper.chatInfoBackgroundColorProductSold
        case .Available:
            return UIColor.clearColor()
        }
    }

    var iconImage: UIImage {
        switch self {
        case .Forbidden:
            return UIImage(named: "ic_alert_yellow") ?? UIImage()
        case .Blocked:
            return UIImage(named: "ic_blocked_white") ?? UIImage()
        case .BlockedBy:
            return UIImage(named: "ic_blocked_white_line") ?? UIImage()
        case .ProductInactive:
            return UIImage(named: "ic_alert_yellow") ?? UIImage()
        case .ProductSold:
            return UIImage(named: "ic_sold_white") ?? UIImage()
        case .Available:
            return UIImage()
        }
    }

    var isHidden: Bool {
        switch self {
        case .Forbidden, .Blocked, .BlockedBy, .ProductInactive, .ProductSold:
            return false
        case .Available:
            return true
        }
    }

    var heightValue: CGFloat {
        switch self {
        case .Forbidden, .Blocked, .BlockedBy, .ProductInactive, .ProductSold:
            return 28
        case .Available:
            return 0
        }
    }
}

public class RelationInfoView: UIView {

    static let defaultHeight: CGFloat = 28

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chatInfoIcon: UIImageView!
    @IBOutlet weak var chatInfoLabel: UILabel!

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    public static func relationInfoView() -> RelationInfoView {
        return NSBundle.mainBundle().loadNibNamed("RelationInfoView", owner: self, options: nil).first as! RelationInfoView
    }

    public init(status: ChatInfoViewStatus, frame: CGRect) {
        super.init(frame: frame)
        setupUIForStatus(status)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupUIForStatus(status: ChatInfoViewStatus) {
        setupBasicUI()

        // Status dependant setup
        heightConstraint.constant = status.heightValue
        backgroundColor = status.bgColor
        chatInfoLabel.textColor = status.infoTextColor
        chatInfoLabel.text = status.infoText
        chatInfoIcon.image = status.iconImage
    }

    func setupBasicUI() {
        // Non-Status dependant setup
        containerView.backgroundColor = UIColor.clearColor()
        chatInfoLabel.font = StyleHelper.chatInfoLabelFont
        chatInfoLabel.textAlignment = .Left
        chatInfoIcon.contentMode = .ScaleAspectFill
        chatInfoIcon.clipsToBounds = true
    }
}
