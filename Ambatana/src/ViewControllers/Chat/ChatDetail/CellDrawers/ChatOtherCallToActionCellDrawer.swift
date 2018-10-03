import Foundation
import LGCoreKit

final class ChatOtherCallToActionCellDrawer: BaseChatCellDrawer<ChatOtherCallToActionCell> {

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatOtherCallToActionCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        if case .cta(let ctaData, let ctas) = message.type {
            cell.setupWith(ctaData: ctaData, ctas: ctas, dateText: message.sentAt?.formattedTime())
            cell.set(bubbleBackgroundColor: bubbleColor)
            cell.set(userAvatar: message.userAvatarData?.avatarImage, avatarAction: message.userAvatarData?.avatarAction)
            cell.configure(for: .individualCell)
        }	
    }
}

