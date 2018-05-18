//
//  Collection+Safe.swift
//  LetGo
//
//  Created by Tomas Cobo on 09/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

extension Collection {
    subscript (safeAt index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
