//
//  Equatable+Index.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 17/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension Equatable {
    func index(in: [Self]) -> Int? {
        return `in`.index(of: self)
    }
}
