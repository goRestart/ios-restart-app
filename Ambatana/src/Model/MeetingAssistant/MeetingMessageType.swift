//
//  MeetingMessageType.swift
//  LetGo
//
//  Created by Dídac on 26/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

enum MeetingMessageType: String {
    case requested = "meeting_requested"
    case accepted = "meeting_accepted"
    case rejected = "meeting_rejected"

    var status: MeetingStatus {
        switch self {
        case .requested:
            return .pending
        case .accepted:
            return .accepted
        case .rejected:
            return .rejected
        }
    }
}
