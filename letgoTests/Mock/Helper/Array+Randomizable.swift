//
//  Array+Randomizable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 28/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//


extension Array {
    public func random() -> Element? {
        guard !isEmpty else { return nil }
        let idx = Int.random(0, count-1)
        return self[idx]
    }
}
