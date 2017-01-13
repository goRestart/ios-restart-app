//
//  SequenceType+Categorize.swift
//  LGCoreKit
//
//  Created by Dídac on 09/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

extension Sequence {
    func categorise<U : Hashable>(_ keyFunc: (Iterator.Element) -> U?) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            guard let key = keyFunc(el) else { continue }
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}
