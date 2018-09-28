import Foundation
import LGCoreKit

final class ChatMyCallToActionCellDrawer: BaseChatCellDrawer<ChatMyCallToActionCell> {

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatMyCallToActionCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        if case .cta(let ctaData, let ctas) = message.type {
            cell.setupWith(ctaData: ctaData, ctas: ctas, dateText: message.sentAt?.formattedTime())
            cell.configure(for: .individualCell, type: .callToAction)
        }
    }
}

