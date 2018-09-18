import Foundation
import LGCoreKit

final class ChatSystemDrawer: BaseChatCellDrawer<ChatSystemCell> {
    
    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }
    
    override func draw(_ cell: ChatSystemCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        if case .system(let message) = message.type {
            cell.set(message: message)
        }
    }
}
