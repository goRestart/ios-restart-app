//
//  CollectionType+Merge.swift
//  LetGo
//
//  Created by Eli Kohen on 22/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

extension Collection where Index == Int {
    /// Return a copy of `self` with its elements shuffled
    func merged<C : Collection>(with collection: C, matcher: (Self.Iterator.Element) -> Bool,
                sortBy comparator: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> [Self.Iterator.Element] where C.Iterator.Element == Self.Iterator.Element {
        var list = Array<Self.Iterator.Element>(self)
        list.merge(another: collection, matcher: matcher, sortBy: comparator)
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func merge<C : Collection>(another collection: C, matcher: (Self.Iterator.Element) -> Bool,
                        sortBy comparator: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) where C.Iterator.Element == Self.Iterator.Element {
        // empty and single-element collections don't shuffle
        if count < 2 { return }

        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
