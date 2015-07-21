//
//  PAContactSendService.swift
//  LGCoreKit
//
//  Created by Dídac on 16/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAContactSendService: ContactSendService {
    
    // MARK: - Lifecycle
    
    public init() {
        
    }
    
    // MARK: - UserSaveService
    
    public func sendContact(contact: Contact, result: ContactSendServiceResult?) {
        if let theContact  = contact as? PAContact {
            theContact.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                
                if success {
                    result?(Result<Contact, ContactSendServiceError>.success(theContact))
                }
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<Contact, ContactSendServiceError>.failure(.Network))
                    default:
                        result?(Result<Contact, ContactSendServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<Contact, ContactSendServiceError>.failure(.Internal))
                }
            }
        }
        else {
            result?(Result<Contact, ContactSendServiceError>.failure(.Internal))
        }
    }
}
