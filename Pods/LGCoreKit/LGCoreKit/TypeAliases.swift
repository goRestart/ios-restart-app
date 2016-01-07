//
//  TypeAliases.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 02/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

struct ResultResult<T, Error : ErrorType> {
    typealias t = Result<T, Error>
}
