//
//  ChatInfoView.swift
//  LetGo
//
//  Created by Dídac on 17/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

public enum ChatInfoViewStatus: Int {

    case Forbidden
    case MeBlocked
    case OtherBlocked
    case ProductInactive
    case ProductSold
    case NoInfo

    var infoText: String {
        switch self {
        case .Forbidden:
            return LGLocalizedString.accountDeactivated
        case .MeBlocked:
            return LGLocalizedString.chatBlockedByMeLabel
        case .OtherBlocked:
            return LGLocalizedString.chatBlockedByOtherLabel
        case .ProductInactive:
            return LGLocalizedString.chatProductInactiveLabel
        case .ProductSold:
            return LGLocalizedString.chatProductSoldLabel
        case .NoInfo:
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
        case .MeBlocked:
            return StyleHelper.chatInfoBackgrounColorMeBlocked
        case .OtherBlocked:
            return StyleHelper.chatInfoBackgrounColorOtherBlocked
        case .ProductInactive:
            return StyleHelper.chatInfoBackgroundColorProductInactive
        case .ProductSold:
            return StyleHelper.chatInfoBackgroundColorProductSold
        case .NoInfo:
            return UIColor.clearColor()
        }
    }

    var iconImage: UIImage {
        switch self {
        case .Forbidden:
            return UIImage(named: "ic_alert_yellow") ?? UIImage()
        case .MeBlocked:
            return UIImage(named: "ic_blocked_white_line") ?? UIImage()
        case .OtherBlocked:
            return UIImage(named: "ic_blocked_white") ?? UIImage()
        case .ProductInactive:
            return UIImage(named: "ic_alert_yellow") ?? UIImage()
        case .ProductSold:
            return UIImage(named: "ic_sold_white") ?? UIImage()
        case .NoInfo:
            return UIImage()
        }
    }

    var isHidden: Bool {
        switch self {
        case .Forbidden, .MeBlocked, .OtherBlocked, .ProductInactive, .ProductSold:
            return false
        case .NoInfo:
            return true
        }
    }
}

public class ChatInfoView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chatInfoIcon: UIImageView!
    @IBOutlet weak var chatInfoLabel: UILabel!

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    public static func chatInfoView() -> ChatInfoView? {
        return NSBundle.mainBundle().loadNibNamed("ChatInfoView", owner: self, options: nil).first as? ChatInfoView
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
        hidden = status.isHidden
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
