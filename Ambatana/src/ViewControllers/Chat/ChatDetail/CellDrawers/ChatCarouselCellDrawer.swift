import Foundation
import LGCoreKit

final class ChatCarouselDrawer: BaseChatCellDrawer<ChatCarouselCollectionCell> {
    
    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }
    
    override func draw(_ cell: ChatCarouselCollectionCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        if case .carousel(let cards, _) = message.type {
            cell.set(cards: cards)
        }
    }
}
