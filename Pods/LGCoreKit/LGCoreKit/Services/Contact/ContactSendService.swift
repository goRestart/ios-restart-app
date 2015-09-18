//
//  ContactSendService.swift
//  LGCoreKit
//
//  Created by Dídac on 16/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ContactSendServiceError {
    case Network
    case Internal
    case InvalidEmail
}

public typealias ContactSendServiceResult = (Result<Contact, ContactSendServiceError>) -> Void

public protocol ContactSendService {
    
    /**
    Sends the contact.
    
    :param: contact -> the contact (email, title, message...).
    :param: result The closure containing the result.
    */
    func sendContact(contact: Contact, result: ContactSendServiceResult?)
}