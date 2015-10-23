//
//  Contact.swift
//  LGCoreKit
//
//  Created by Dídac on 16/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol Contact: BaseModel {
    
    var email: String? { get set }
    var title: String? { get set }
    var message: String? { get set }
    
    var user: User? { get set }
}