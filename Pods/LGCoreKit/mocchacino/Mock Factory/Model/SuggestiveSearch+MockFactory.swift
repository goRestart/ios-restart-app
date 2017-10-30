//
//  SuggestiveSearch+MockFactory.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 04/10/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

extension SuggestiveSearch: MockFactory {
    public static func makeMock() -> SuggestiveSearch {
        let name = String.makeRandom()
        let category = ListingCategory.makeMock()
        switch Int.makeRandom(min: 0, max: 2) {
        case 0:
            return .term(name: name)
        case 1:
            return .category(category: category)
        case 2:
            return .termWithCategory(name: name,
                                     category: category)
        default:
            return .term(name: name)
        }
    }
}
