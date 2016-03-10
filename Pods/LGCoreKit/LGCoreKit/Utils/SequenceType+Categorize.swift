//
//  SequenceType+Categorize.swift
//  LGCoreKit
//
//  Created by Dídac on 09/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

extension SequenceType {
    func categorise<U : Hashable>(@noescape keyFunc: Generator.Element -> U?) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            guard let key = keyFunc(el) else { continue }
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}