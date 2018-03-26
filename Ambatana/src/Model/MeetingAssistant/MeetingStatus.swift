//
//  MeetingStatus.swift
//  LetGo
//
//  Created by Dídac on 26/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation


enum MeetingStatus: Int {
    case pending = 0
    case accepted = 1
    case rejected = 2

    init(value: Int) {
        switch value {
        case 0:
            self = .pending
        case 1:
            self = .accepted
        case 2:
            self = .rejected
        default:
            self = .pending
        }
    }
}
