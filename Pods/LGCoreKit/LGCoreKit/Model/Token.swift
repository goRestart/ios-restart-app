//
//  Token.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 26/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum AuthLevel: Int {
    case Nonexistent
    case Installation
    case User
}

struct Token {
    let value: String?
    var actualValue: String? {
        return value?.lastComponentSeparatedByCharacter(" ")
    }
    var level: AuthLevel
}
