//
//  TypeAliases.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 02/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

struct ResultResult<T, E : Error> {
    typealias t = Result<T, E>
}
