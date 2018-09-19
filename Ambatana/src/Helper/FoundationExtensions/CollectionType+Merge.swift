//
//  CollectionType+Merge.swift
//  LetGo
//
//  Created by Eli Kohen on 22/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

extension Collection where Index == Int {
    /// Return a list "copy" of `self` with its elements merged
    func merging<C : Collection>(with collection: C, matcher: (Self.Iterator.Element, Self.Iterator.Element) -> Bool,
                sortBy areInIncreasingOrder: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> [Self.Iterator.Element] where C.Iterator.Element == Self.Iterator.Element {
        var list = Array<Self.Iterator.Element>(self)
        list.merge(another: collection, matcher: matcher, sortBy: areInIncreasingOrder)
        return list
    }
}

extension Array {
    mutating func merge<C : Collection>(another collection: C, matcher: (Element, Element) -> Bool,
                        sortBy areInIncreasingOrder: (Element, Element) -> Bool) where C.Iterator.Element == Element {
        guard !collection.isEmpty else { return }
        guard !isEmpty else {
            self.append(contentsOf: collection)
            return
        }

        var itemsToAdd = [Element]()
        collection.forEach { newElement in
            let foundIndex = index { matcher($0, newElement) }
            if let foundIndex = foundIndex {
                self[foundIndex] = newElement
            } else {
                itemsToAdd.append(newElement)
            }
        }

        append(contentsOf: itemsToAdd)
        sort(by: areInIncreasingOrder)
    }
}

extension Array where Element: Equatable {
    mutating func removeIfContainsElseAppend(_ element: Element) {
        if let index = index(where: { $0 == element }) {
            remove(at: index)
        } else {
            append(element)
        }
    }
    
    mutating func removeIfContains(_ element: Element) {
        guard let index = index(where: { $0 == element }) else { return }
        remove(at: index)
    }
}
