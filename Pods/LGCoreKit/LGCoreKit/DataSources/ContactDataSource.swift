//
//  ContactDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 25/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

typealias ContactDataSourceCompletion = (Result<Void, ApiError>) -> Void


protocol ContactDataSource {
    func send(_ email: String, title: String, message: String, completion: ContactDataSourceCompletion?)
}
