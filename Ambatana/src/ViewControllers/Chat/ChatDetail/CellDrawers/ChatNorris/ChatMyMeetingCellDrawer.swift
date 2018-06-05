import Foundation
import LGCoreKit
import LGComponents

final class ChatMyMeetingCellDrawer: BaseChatCellDrawer<ChatMyMeetingCell> {

    override func draw(_ cell: ChatMyMeetingCell, message: ChatViewMessage) {
        switch message.type {
        case let .meeting(_, date, locationName, coordinates, status, _):
            cell.setupLocation(locationName: locationName,
                               coordinates: coordinates,
                               date: date ?? Date(),
                               status: status ?? .pending)
            cell.messageDateLabel.text = message.sentAt?.formattedTime()
            cell.checkImageView.image = nil
            drawCheckForMessage(cell, message: message)
        default:
            break
        }
    }

    private func drawCheckForMessage(_ cell: ChatMyMeetingCell, message: ChatViewMessage) {
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
            cell.checkImageView.image = nil
        }
    }
}
