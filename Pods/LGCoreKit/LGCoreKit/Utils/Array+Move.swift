//
//  Array+Move.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 06/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

extension Array {
    mutating func move(fromIndex: Int, toIndex: Int) {
        let element = remove(at: fromIndex)
        insert(element, at: toIndex)
    }
}
 
