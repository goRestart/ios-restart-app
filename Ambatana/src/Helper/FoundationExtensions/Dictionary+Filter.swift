//
//  Dictionary+Filter.swift
//  LetGo
//
//  Created by Dídac on 03/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

extension Dictionary {
    func filter(keys: [Key]) -> [Key: Value] {
        return filter { keys.contains($0.key) }.reduce([:]) { (dict, keyValue) -> [Key: Value] in
            var newDict = dict
            newDict[keyValue.0] = keyValue.1
            return newDict
        }
    }
}
