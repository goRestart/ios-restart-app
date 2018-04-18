//
//  CarSellerType+LG.swift
//  LetGo
//
//  Created by Tomas Cobo on 16/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

extension CarSellerType {
    func title(feature: FilterSearchCarSellerType) -> String {
        switch self {
        case .individual:
            return FilterCarSection.firstSection.title(feature: feature)
        case .professional:
            return FilterCarSection.secondSection.title(feature: feature)
        }
    }
    var filterCarSection: FilterCarSection {
        switch self {
        case .individual:
            return .firstSection
        case .professional:
            return .secondSection
        }
    }
}

extension Array where Element == CarSellerType {
    func filterCarSectionsFor(feature: FilterSearchCarSellerType) -> [FilterCarSection] {
        let sections = self.map{ $0.filterCarSection }
        
        //  UI is selected differently depending on AB Test.
        if !feature.isMultiselection,   //  Single selectable
            sections.count != 1 {       //  0 or 2 options selected -> UI is firstRow (All)
            return [.firstSection]
        }
        return sections
    }
}
