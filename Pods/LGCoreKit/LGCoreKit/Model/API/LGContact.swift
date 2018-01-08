//
//  LGContact.swift
//  LGCoreKit
//
//  Created by Dídac on 04/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol Contact {
    var email: String { get }
    var title: String { get }
    var message: String { get }
}

public struct LGContact: Contact {
    public let email: String
    public let title: String
    public let message: String
}
