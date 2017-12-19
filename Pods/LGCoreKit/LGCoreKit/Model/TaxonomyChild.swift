//
//  TaxonomyChild.swift
//  LGCoreKit
//
//  Created by Dídac on 17/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol TaxonomyChild {
    var id: Int { get }
    var type: TaxonomyChildType { get }
    var name: String { get }
    var highlightOrder: Int? { get }
    var highlightIcon: URL? { get }
    var image: URL? { get }
}

/*
 Custom equatable method. TaxonomyChild can not implement Equatable because it is not a type
 */
public func ==(lhs: TaxonomyChild?, rhs: TaxonomyChild?) -> Bool {
    guard let lhs = lhs else {
        guard let _ = rhs else { return true }
        return false
    }
    guard let rhs = rhs else { return false }

    return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.highlightOrder == rhs.highlightOrder &&
        lhs.highlightIcon?.absoluteString == rhs.highlightIcon?.absoluteString &&
        lhs.image?.absoluteString == rhs.image?.absoluteString
}

public enum TaxonomyChildType: String {
    case superKeyword = "superkeyword"
    case category = "category"
}

public func ==(lhs: TaxonomyChildType, rhs: TaxonomyChildType) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
