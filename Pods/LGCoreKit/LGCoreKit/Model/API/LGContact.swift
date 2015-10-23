//
//  LGContact.swift
//  LGCoreKit
//
//  Created by Dídac on 04/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


public class LGContact: LGBaseModel, Contact {
    
    public var email: String?
    public var title: String?
    public var message: String?
    
    public var user: User?
    
    public override init() {
        super.init()
    }
}
