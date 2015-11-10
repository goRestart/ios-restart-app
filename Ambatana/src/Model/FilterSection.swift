//
//  FilterSection.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

public enum FilterSection {
    case Distance, Categories, SortBy
}

extension FilterSection {
    
    //TODO: LOCALIZE!!
    
    public var name : String {
        switch(self) {
        case .Distance:
            return "DISTANCE"
        case .Categories:
            return "CATEGORIES"
        case .SortBy:
            return "SORT BY"
        }
    }
    
}
