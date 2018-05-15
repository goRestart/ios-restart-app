//
//  OrderCondition.swift
//  LetGo
//
//  Created by Stephen Walsh on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

/*
 Use me for ordering / updating / inserting / deleting
 elements in  collections
 */

// FIXME: Move to corekit

enum OrderCondition<T> {
    case first
    case last
    case before(item: T)
    case after(item: T)
    case exactly(index: Int)
}
