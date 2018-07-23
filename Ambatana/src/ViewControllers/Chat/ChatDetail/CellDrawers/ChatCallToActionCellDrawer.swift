import Foundation
import LGCoreKit

final class ChatCallToActionCellDrawer: BaseChatCellDrawer<ChatCallToActionCell> {

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatCallToActionCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        switch message.type {
        case .cta(let ctaData, let ctas):
            cell.setupWith(ctaData: ctaData, ctas: ctas, dateText: message.sentAt?.formattedTime())
            cell.set(bubbleBackgroundColor: bubbleColor)
            cell.set(userAvatar: message.userAvatarData?.avatarImage, avatarAction: message.userAvatarData?.avatarAction)
            cell.configure(for: .individualCell, type: .callToAction)
        default:
            break
        }
    }
}

