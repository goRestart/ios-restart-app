//
//  FeedSectionMapCollection.swift
//  LetGo
//
//  Created by Stephen Walsh on 07/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


final class FeedSectionMapCollection {
    
    
    // MARK: OrderConditionable conformance
    typealias Orderable = FeedSectionMapType
    
    private let sectionsVariable: Variable<[FeedSectionMap]> = Variable([FeedSectionMap]())
    
    var sortedSections: [FeedSectionMap] {
        return sectionsVariable.value
    }
    
    var sectionsDriver: Driver<[FeedSectionMap]> {
        return sectionsVariable.asDriver()
    }
    
    func populate(with sections: [FeedSectionMap]) {
        sectionsVariable.value = sections
    }
    
    func append(with sections: [FeedSectionMap]) {
        sectionsVariable.value.append(contentsOf: sections)
    }
    
    func containsSection(ofType type: FeedSectionMapType) -> Bool {
        return sectionsVariable.value.contains(where: { $0.type == type })
    }
    
    func removeSection(ofType type: FeedSectionMapType) {
        sectionsVariable.value = sectionsVariable.value.filter({!($0.type == type)})
    }
    
    func insert(section: FeedSectionMap,
                forOrderCondition orderCondition: OrderCondition<FeedSectionMapType>? = nil) {
        
        guard let orderCondition = orderCondition,
            let insertIndex = cleanedIndex(forOrderCondition: orderCondition) else {
            sectionsVariable.value.append(section)
            return
        }
        
        sectionsVariable.value.insert(section,
                                      at: insertIndex)
    }
}


// MARK: OrderConditionable conformance
extension FeedSectionMapCollection: OrderConditionable {
    
    internal var orderableDatasource: [Any] {
        return sectionsVariable.value
    }
    
    internal func equatableTypes(lhs: Any, rhs: FeedSectionMapType) -> Bool {
        if let lhs = lhs as? FeedSectionMap {
            return lhs.type == rhs
        }
        
        return false
    }
}
