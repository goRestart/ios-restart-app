import Foundation
import LGComponents
import UIKit

typealias ChatBubbleCell = ChatCellWithBubble & UITableViewCell

enum ChatBubbleCellPosition {
    case firstInGroup
    case midInGroup
    case lastInGroup
    case individualCell

    var bottomMargin: CGFloat {
        switch self {
        case .firstInGroup, .midInGroup:
            return 2
        case .lastInGroup, .individualCell:
            return 16
        }
    }

    var showOtherUserAvatar: Bool {
        switch self {
        case .firstInGroup, .individualCell: return true
        case .lastInGroup, .midInGroup: return false
        }
    }

    // For iOS11 or newer
    func maskedCorners(for type: ChatBubbleCellType) -> CACornerMask {
        switch (type, self) {
        case (.askPhoneNumber, _), (_, .individualCell), (.callToAction, _), (.carousel, _), (.system, _):
            return [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case (.myMessage, .firstInGroup):
            return [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        case (.myMessage, .midInGroup):
            return [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        case (.myMessage, .lastInGroup):
            return [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
        case (.othersMessage, .firstInGroup):
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case (.othersMessage, .midInGroup):
            return [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case (.othersMessage, .lastInGroup):
            return [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }


    // For ios10 or older
    func roundedCorners(for type: ChatBubbleCellType) -> UIRectCorner {
        switch (type, self) {
        case (.askPhoneNumber, _), (_, .individualCell), (.callToAction, _), (.carousel, _), (.system, _):
            return .allCorners
        case (.myMessage, .firstInGroup):
            return [.topLeft, .bottomLeft, .topRight]
        case (.myMessage, .midInGroup):
            return [.topLeft, .bottomLeft]
        case (.myMessage, .lastInGroup):
            return [.topLeft, .bottomLeft, .bottomRight]
        case (.othersMessage, .firstInGroup):
            return [.topRight, .bottomRight, .topLeft]
        case (.othersMessage, .midInGroup):
            return [.topRight, .bottomRight]
        case (.othersMessage, .lastInGroup):
            return [.topRight, .bottomRight, .bottomLeft]
        }
    }
}

struct ChatBubbleLayout {
    static let avatarSize: CGFloat = 36
    static let margin: CGFloat = 8
    static let bigMargin: CGFloat = 12
    static let veryBigMargin: CGFloat = 26
    static let cornerRadius: CGFloat = 16
    static let minBubbleMargin: CGFloat = 52
    static let checkImageSize: CGFloat = 16
    static let dateHeight: CGFloat = 15
}

protocol ChatCellWithBubble: class {
    var bubbleView: UIView { get }
    var messageLabel: UILabel { get }
    var dateLabel: UILabel { get }

    var bubbleBottomMargin: NSLayoutConstraint? { get }
}

extension ChatCellWithBubble {
    func set(text: String) {
        switch text.emojiOnlyCount {
        case 1:
            messageLabel.font = UIFont.systemRegularFont(size: 49)
        case 2:
            messageLabel.font = UIFont.systemRegularFont(size: 37)
        case 3:
            messageLabel.font = UIFont.systemRegularFont(size: 27)
        default:
            messageLabel.font = UIFont.bigBodyFont
        }
        messageLabel.text = text
    }

    func setDefaultAccessibilityIds() {
        messageLabel.set(accessibilityId: .chatCellMessageLabel)
        dateLabel.set(accessibilityId: .chatCellDateLabel)
    }

    func configure(for position: ChatBubbleCellPosition, type: ChatBubbleCellType) {
        bubbleBottomMargin?.constant = -position.bottomMargin

        bubbleView.cornerRadius = ChatBubbleLayout.cornerRadius

        // FIXME: This snippet makes the cells not show their background color on ios < 11 and is not needed yet
        // I'm commenting it now as a quick fix, and it will be propperly fixed when implementing task:
        // https://ambatana.atlassian.net/browse/ABIOS-3752
        // that will make use of it

//        if #available(iOS 11.0, *) {
//            bubbleView.layer.maskedCorners = position.maskedCorners(for: type)
//        } else {
//            bubbleView.setRoundedCorners(position.roundedCorners(for: type), cornerRadius: ChatBubbleLayout.cornerRadius)
//        }
    }
}
