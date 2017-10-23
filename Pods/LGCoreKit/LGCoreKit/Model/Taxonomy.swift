//
//  Taxonomy.swift
//  LGCoreKit
//
//  Created by Dídac on 17/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol Taxonomy {
    var name: String { get }
    var icon: URL? { get }
    var children: [TaxonomyChild] { get }
}

/*
 Custom equatable method. Taxonomy can not implement Equatable because it is not a type
 */
public func ==(lhs: Taxonomy?, rhs: Taxonomy?) -> Bool {
    guard let lhs = lhs else {
        guard let _ = rhs else { return true }
        return false
    }
    guard let rhs = rhs else { return false }
    guard lhs.name == rhs.name && lhs.icon?.absoluteString == rhs.icon?.absoluteString else { return false }
    guard lhs.children.count == rhs.children.count else { return false }
    for (index, taxChild) in lhs.children.enumerated() {
        guard taxChild == rhs.children[index] else { return false }
    }
    return true
}
