//
//  OrderConditionable.swift
//  LetGo
//
//  Created by Stephen Walsh on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation


// FIXME: Move to corekit

protocol OrderConditionable {
    associatedtype Orderable
    var orderableDatasource: [Any] { get }
    func equatableTypes(lhs: Any, rhs: Orderable) -> Bool
}

extension OrderConditionable {
    
    func cleanedIndex(forOrderCondition orderCondition: OrderCondition<Orderable>) -> Int? {
        return clean(forIndex: index(forOrderCondition: orderCondition))
    }
    
    private func index(forOrderCondition orderCondition: OrderCondition<Orderable>) -> Int? {
        
        switch orderCondition {
        case .first: return 0
        case .last: return orderableDatasource.endIndex
        case .after(let item):
            if let itemIndex = firstIndex(ofType: item) {
                return orderableDatasource.index(after: itemIndex)
            }
        case .before(let item):
            if let itemIndex = firstIndex(ofType: item) {
                return itemIndex
            }
        case .exactly(let index):
            return index
        }
        
        return nil
    }
    
    
    // MARK:- Returns an index of the first instance a supplied type
    private func firstIndex(ofType type: Orderable) -> Int? {
        for (index, item) in orderableDatasource.enumerated().makeIterator() {
            if equatableTypes(lhs: item, rhs: type) {
                return index
            }
        }
        
        return nil
    }
    
    
    // MARK:- Returns an index in bounds
    private func clean(forIndex index: Int?) -> Int? {
        guard let index = index,
            index >= 0,
            index < orderableDatasource.count else {
                return nil
        }
        return index
    }
}
