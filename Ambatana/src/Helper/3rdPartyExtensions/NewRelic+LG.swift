//
//  NewRelic+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 22/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

extension NewRelicAgent {
    
    enum SessionType: String {
        case App = "app"
        case User = "user"
        case Guest = "guest"
    }
    
    static func addSessionAttributes() {
        var sessionType: String = SessionType.Guest.rawValue
        var sessionId: String?
        if let userId = Core.myUserRepository.myUser?.objectId {
            sessionType =  SessionType.User.rawValue
            sessionId = userId
        }else if let installationId = Core.installationRepository.installation?.objectId {
            sessionType = SessionType.App.rawValue
            sessionId = installationId
        }
        NewRelic.setAttribute("session_type", value: sessionType)
        NewRelic.setAttribute("session_subject_id", value: sessionId)
    }
}
