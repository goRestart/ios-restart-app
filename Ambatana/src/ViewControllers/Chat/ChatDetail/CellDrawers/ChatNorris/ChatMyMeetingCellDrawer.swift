//
//  ChatMyMeetingCellDrawer.swift
//  LetGo
//
//  Created by Dídac on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ChatMyMeetingCellDrawer: BaseChatCellDrawer<ChatMyMeetingCell> {

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatMyMeetingCell, message: ChatViewMessage) {
        switch message.type {
        case let .chatNorris(type, date, locationName, coordinates, status):
            cell.setupLocation(locationName: locationName, coordinates: coordinates, date: date ?? Date(), status: status ?? .pending)
        default:
            break
        }
    }
}
