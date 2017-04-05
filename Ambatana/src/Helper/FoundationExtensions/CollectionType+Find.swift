//
//  CollectionType+Find.swift
//  LetGo
//
//  Created by Eli Kohen on 05/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

extension Collection {
    func find(where matcher: (Iterator.Element) -> Bool) -> Iterator.Element? {
        guard let index = index(where: matcher) else { return nil }
        return self[index]
    }
}
