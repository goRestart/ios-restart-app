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
public typealias ContactCompletion = (ContactResult) -> Void

public protocol ContactRepository {
    func send(_ contact: Contact, completion: ContactCompletion?)
}
