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
    
    var title: String {
        return filterCarSection.title
    }
    var filterCarSection: FilterCarSection {
        return isProfessional ? .dealership : .individual
    }
}

extension Array where Element == UserType {
    var filterCarSections: [FilterCarSection] {
        return map{ $0.filterCarSection }
    }
    
    var containsBothCarSellerTypes: Bool {
        return contains(.user) && contains(.pro)
    }
    
    func toogleFilterCarSection(filter: FilterCarSection) -> [UserType] {
        var carSections = self
        carSections.removeIfContainsElseAppend(filter.carSellerType)
        return carSections
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
