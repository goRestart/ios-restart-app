//
//  LGContactRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

final class LGContactRepository: ContactRepository {
    let contactDataSource: ContactDataSource


    // MARK: - Lifecycle

    init(contactDataSource: ContactDataSource) {
        self.contactDataSource = contactDataSource
    }


    // MARK: - Public

    func send(_ contact: Contact, completion: ContactCompletion?) {
        contactDataSource.send(contact.email, title: contact.title, message: contact.message) { result in
            if let _ = result.value {
                completion?(ContactResult(value: contact))
            } else if let error = result.error {
                completion?(ContactResult(error: RepositoryError(apiError: error)))
            }
        }
    }
}
