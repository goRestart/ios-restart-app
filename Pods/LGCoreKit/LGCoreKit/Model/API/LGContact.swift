//
//  LGContact.swift
//  LGCoreKit
//
//  Created by Dídac on 04/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


public struct LGContact: Contact {
    public let email: String
    public let title: String
    public let message: String

    public init(email: String, title: String, message: String) {
        self.email = email
        self.title = title
        self.message = message
    }
}
