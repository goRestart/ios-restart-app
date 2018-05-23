//
//  ChatConversationListCellType.swift
//  LetGo
//
//  Created by Dídac on 14/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

enum ChatConversationListCellType {
    case buying
    case selling
    case assistant

    init(userType: UserType, amISelling: Bool) {
        switch userType {
        case .dummy:
            self = .assistant
        case .pro, .user:
            if amISelling {
                self = .selling
            } else {
                self = .buying
            }
        }
    }
}
