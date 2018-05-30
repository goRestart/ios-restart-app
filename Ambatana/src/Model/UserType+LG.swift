//
//  UserType+LG.swift
//  LetGo
//
//  Created by Tomas Cobo on 16/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

extension UserType {
    
    var isProfessional: Bool { return self == .pro }

    var isDummy: Bool { return self == .dummy }
    
    func title(feature: FilterSearchCarSellerType) -> String {
        return isProfessional ? FilterCarSection.secondSection.title(feature: feature) :
            FilterCarSection.firstSection.title(feature: feature)
    }
    var filterCarSection: FilterCarSection {
        return isProfessional ? .secondSection : .firstSection
    }
}

extension Array where Element == UserType {
    func filterCarSectionsFor(feature: FilterSearchCarSellerType) -> [FilterCarSection] {
        let sections = self.map{ $0.filterCarSection }
        
        //  UI is selected differently depending on AB Test.
        if !feature.isMultiselection,   //  Single selectable
            sections.count != 1 {       //  0 or 2 options selected -> UI is firstRow (All)
            return [.firstSection]
        }
        return sections
    }

    func carSectionsFrom(feature: FilterSearchCarSellerType, filter: FilterCarSection) -> [UserType] {
        var carSections = self
        if feature.isMultiselection {
            let carSellerType = filter.carSellerType
            carSections.removeIfContainsElseAppend(carSellerType)
        } else {
            carSections = filter.isFirstSection ? [.user, .pro] : [.pro]
        }
        return carSections
    }
    
    var containsBothCarSellerTypes: Bool {
        return contains(.user) && contains(.pro)
    }

    var trackValue: String {
        if isEmpty {
            return TrackSellerTypeValues.none.rawValue
        } else if containsBothCarSellerTypes {
            return TrackSellerTypeValues.all.rawValue
        }
        return contains(.user) ? TrackSellerTypeValues.user.rawValue : TrackSellerTypeValues.professional.rawValue
    }
}

private enum TrackSellerTypeValues: String {
    case none = "none"
    case user = "private"
    case professional = "professional"
    case all = "all"
}
