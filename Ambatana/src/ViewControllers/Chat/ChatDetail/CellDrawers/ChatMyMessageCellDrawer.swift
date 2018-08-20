import Foundation
import LGCoreKit
import LGComponents

final class ChatMyMessageCellDrawer: BaseChatCellDrawer<ChatMyMessageCell> {

    var showDisclose: Bool = false
 
    private let rightMarginMessageTextDefault: CGFloat = 10
    private let rightMarginWithDisclosure: CGFloat = 38
    
    init(showDisclose: Bool, autoHide: Bool) {
        self.showDisclose = showDisclose
        super.init(autoHide: autoHide)
    }
    
    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatMyMessageCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        cell.set(text: message.value)
        cell.dateLabel.text = message.sentAt?.formattedTime()
        cell.checkImageView.image = nil
        cell.configure(for: .individualCell, type: .myMessage)
        drawCheckForMessage(cell, message: message)
        drawDisclosureForMessage(cell, disclosure: showDisclose)
    }
    
    // MARK: - private methods

    private func drawCheckForMessage(_ cell: ChatMyMessageCell, message: ChatViewMessage) {
        guard let status = message.status else {
            cell.checkImageView.image = nil
            return
        }
        switch status {
        case .sent:
            cell.checkImageView.image = R.Asset.Chat.icTickSent.image
        case .received:
            cell.checkImageView.image = R.Asset.Chat.icDobleReceived.image
        case .read:
            cell.checkImageView.image = R.Asset.Chat.icDobleRead.image
        case .unknown:
            cell.checkImageView.image = R.Asset.Chat.icWatch.image
        }
    }
    
    private func drawDisclosureForMessage(_ cell: ChatMyMessageCell, disclosure: Bool) {
        if disclosure {
            cell.disclosureImageView.image = R.Asset.IconsButtons.icDisclosureChat.image
            cell.marginRightConstraints.forEach { $0.constant = -rightMarginWithDisclosure }
        } else {
            cell.disclosureImageView.image = nil
            cell.marginRightConstraints.forEach { $0.constant = -rightMarginMessageTextDefault }
        }
        
    }
}
