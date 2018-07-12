//
//  Token.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 26/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum AuthLevel: Int {
    case nonexistent
    case installation
    case user
}

extension AuthLevel {
    var eventAuthLevel: EventParameterAuthLevel {
        switch self {
        case .nonexistent: return EventParameterAuthLevel.nonexistent
        case .installation: return EventParameterAuthLevel.installation
        case .user: return EventParameterAuthLevel.user
        }
    }
}

struct Token {
    let value: String?
    var actualValue: String? {
        return value?.lastComponentSeparatedByCharacter(" ")
    }
    var level: AuthLevel
}
