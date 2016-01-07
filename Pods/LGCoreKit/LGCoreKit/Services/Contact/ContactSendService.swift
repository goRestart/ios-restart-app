//
//  ContactSendService.swift
//  LGCoreKit
//
//  Created by Dídac on 16/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ContactSendServiceError: ErrorType {
    case Network
    case Internal
    case InvalidEmail
    
    
    init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case .Internal, .Unauthorized, .NotFound, .AlreadyExists, .Scammer, .InternalServerError:
            self = .Internal
        }
    }
}

public typealias ContactSendServiceResult = Result<Contact, ContactSendServiceError>
public typealias ContactSendServiceCompletion = ContactSendServiceResult -> Void

public protocol ContactSendService {
    
    /**
        Sends the contact.
    
        - parameter contact: The contact (email, title, message...).
        - parameter completion: The completion closure.
    */
    func sendContact(contact: Contact, sessionToken: String?, completion: ContactSendServiceCompletion?)
}