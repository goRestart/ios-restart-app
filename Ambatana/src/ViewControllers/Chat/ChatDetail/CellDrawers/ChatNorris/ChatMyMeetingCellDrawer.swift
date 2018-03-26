//
//  ChatMyMeetingCellDrawer.swift
//  LetGo
//
//  Created by Dídac on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class ChatMyMeetingCellDrawer: BaseChatCellDrawer<ChatMyMeetingCell> {

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatMyMeetingCell, message: ChatViewMessage) {
        switch message.type {
        case let .chatNorris(type, date, locationName, coordinates, status, _):
            cell.setupLocation(locationName: locationName, coordinates: coordinates, date: date ?? Date(), status: status ?? .pending)
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
            cell.checkImageView.image = UIImage(named: "ic_tick_sent")
        case .received:
            cell.checkImageView.image = UIImage(named: "ic_doble_received")
        case .read:
            cell.checkImageView.image = UIImage(named: "ic_doble_read")
        case .unknown:
            cell.checkImageView.image = nil
        }
    }
}
