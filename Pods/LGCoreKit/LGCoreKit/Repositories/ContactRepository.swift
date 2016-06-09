//
//  ContactRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 25/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result


public typealias ContactResult = Result<Contact, RepositoryError>
public typealias ContactCompletion = ContactResult -> Void

public final class ContactRepository {
    let contactDataSource: ContactDataSource
    
    
    // MARK: - Lifecycle
    
    init(contactDataSource: ContactDataSource) {
        self.contactDataSource = contactDataSource
    }
    
    
    // MARK: - Public
    
    public func send(contact: Contact, completion: ContactCompletion?) {
        contactDataSource.send(contact.email, title: contact.title, message: contact.message) { result in
            if let _ = result.value {
                completion?(ContactResult(value: contact))
            } else if let error = result.error {
                completion?(ContactResult(error: RepositoryError(apiError: error)))
            }
        }
    }
}
