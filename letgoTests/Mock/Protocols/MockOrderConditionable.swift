//
//  MockOrderConditionable.swift
//  letgoTests
//
//  Created by Stephen Walsh on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode

class MockOrderConditionable: OrderConditionable {
    
    private var items: [String]
    var orderableDatasource: [Any] {
        return items
    }
    
    typealias Orderable = String
    
    init(items: [String]) {
        self.items = items
    }
    
    func equatableTypes(lhs: Any, rhs: String) -> Bool {
        if let lhs = lhs as? String {
            return lhs == rhs
        }
        
        return false
    }
    
    func insert(item: String,
                withOrderCondition orderCondition: OrderCondition<String>) {
        guard let insertIndex = cleanedIndex(forOrderCondition: orderCondition) else {
                items.append(item)
                return
        }
        
        items.insert(item,
                     at: insertIndex)
    }
    
    func indexOf(item: String) -> Int? {
        return items.index(of: item)
    }
}
