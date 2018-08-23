import Foundation
import LGCoreKit
import LGComponents

final class ChatAskPhoneNumberCellDrawer: BaseChatCellDrawer<ChatAskPhoneNumberCell> {

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatAskPhoneNumberCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        cell.set(text: message.value)
        cell.dateLabel.text = message.sentAt?.formattedTime()
        cell.set(bubbleBackgroundColor: bubbleColor)
        cell.set(userAvatar: message.userAvatarData?.avatarImage, avatarAction: message.userAvatarData?.avatarAction)
        switch message.type {
        case let .askPhoneNumber(_, action):
            cell.buttonAction = action
            cell.leavePhoneNumberButton.isEnabled = action != nil
            cell.leavePhoneNumberButton.setStyle(.secondary(fontSize: .small, withBorder: true))
            cell.leavePhoneNumberButton.setTitle(R.Strings.professionalDealerAskPhoneAddPhoneCellButton, for: .normal)
        default:
            cell.buttonAction = nil
            cell.leavePhoneNumberButton.isHidden = true
        }
        cell.configure(for: .individualCell, type: .askPhoneNumber)
    }
}
