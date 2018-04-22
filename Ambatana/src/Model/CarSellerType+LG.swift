//
//  CarSellerType+LG.swift
//  LetGo
//
//  Created by Tomas Cobo on 16/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

extension CarSellerType {
    
    var isProfessional: Bool { return self == .professional }
    
    func title(feature: FilterSearchCarSellerType) -> String {
        return isProfessional ? FilterCarSection.secondSection.title(feature: feature) :
            FilterCarSection.firstSection.title(feature: feature)
    }
    var filterCarSection: FilterCarSection {
        return isProfessional ? .secondSection : .firstSection
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

    func carSectionsFrom(feature: FilterSearchCarSellerType, filter: FilterCarSection) -> [CarSellerType] {
        var carSections = self
        if feature.isMultiselection {
            let carSellerType = filter.carSellerType
            carSections.removeIfContainsElseAppend(carSellerType)
        } else {
            carSections = filter.isFirstSection ? [.individual, .professional] : [.professional]
        }
        return carSections
    }
    
    var containsBothCarSellerTypes: Bool {
        return contains(.individual) && contains(.professional)
    }

    var trackValue: String {
        if isEmpty {
            return TrackSellerTypeValues.none.rawValue
        } else if containsBothCarSellerTypes {
            return TrackSellerTypeValues.all.rawValue
        }
        return contains(.individual) ? TrackSellerTypeValues.individual.rawValue : TrackSellerTypeValues.professional.rawValue
    }
}

private enum TrackSellerTypeValues: String {
    case none = "none"
    case individual = "private"
    case professional = "professional"
    case all = "all"
}
