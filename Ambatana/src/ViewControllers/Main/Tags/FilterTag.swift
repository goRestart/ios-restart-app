//
//  FilterTag.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum FilterTag: Equatable {
    case location(Place)
    case within(ListingTimeCriteria)
    case orderBy(ListingSortCriteria)
    case category(ListingCategory)
    case taxonomyChild(TaxonomyChild)
    case taxonomy(Taxonomy)
    case secondaryTaxonomyChild(TaxonomyChild)
    case priceRange(from: Int?, to: Int?, currency: Currency?)
    case freeStuff
    case distance(distance: Int)
    
    case make(id: String, name: String)
    case model(id: String, name: String)
    case yearsRange(from: Int?, to: Int?)
    
    case realEstateNumberOfBedrooms(NumberOfBedrooms)
    case realEstateNumberOfBathrooms(NumberOfBathrooms)
    case realEstatePropertyType(RealEstatePropertyType)
    case realEstateOfferType(RealEstateOfferType)
    case realEstateNumberOfRooms(NumberOfRooms)
    case sizeSquareMetersRange(from: Int?, to: Int?)
}

extension FilterTag {
    var isTaxonomy: Bool {
        switch self {
        case .location, .within, .orderBy, .category, .taxonomyChild, .secondaryTaxonomyChild, .priceRange, .freeStuff, .distance, .make, .model, .yearsRange, .realEstateNumberOfBedrooms, .realEstateNumberOfBathrooms, .realEstatePropertyType, .realEstateOfferType, .realEstateNumberOfRooms, .sizeSquareMetersRange:
            return false
        case .taxonomy:
            return true
        }
    }
    
    var taxonomyChild: TaxonomyChild? {
        switch self {
        case .location, .within, .orderBy, .category, .taxonomy, .priceRange, .freeStuff, .distance, .make, .model, .yearsRange, .realEstateNumberOfBedrooms, .realEstateNumberOfBathrooms, .realEstatePropertyType, .realEstateOfferType, .realEstateNumberOfRooms, .sizeSquareMetersRange:
            return nil
        case .taxonomyChild(let taxonomyChild):
            return taxonomyChild
        case .secondaryTaxonomyChild(let taxonomyChild):
            return taxonomyChild
        }
    }
}

func ==(a: FilterTag, b: FilterTag) -> Bool {
    switch (a, b) {
    case (.location, .location): return true
    case (.within(let a),   .within(let b))   where a == b: return true
    case (.orderBy(let a),   .orderBy(let b))   where a == b: return true
    case (.category(let a), .category(let b)) where a == b: return true
    case (.taxonomyChild(let a), .taxonomyChild(let b)) where a == b: return true
    case (.taxonomy(let a), .taxonomy(let b)) where a == b: return true
    case (.secondaryTaxonomyChild(let a), .secondaryTaxonomyChild(let b)) where a == b: return true
    case (.priceRange(let a, let b, _), .priceRange(let c, let d, _)) where a == c && b == d: return true
    case (.freeStuff, .freeStuff): return true
    case (.distance(let distanceA), .distance(let distanceB)) where distanceA == distanceB: return true
    case (.make(let idA, let nameA), .make(let idB, let nameB)) where idA == idB && nameA == nameB: return true
    case (.model(let idA, let nameA), .model(let idB, let nameB)) where idA == idB && nameA == nameB: return true
    case (.yearsRange(let a, let b), .yearsRange(let c, let d)) where a == c && b == d: return true
    case (.realEstateNumberOfBedrooms(let idA), .realEstateNumberOfBedrooms(let idB)) where idA == idB: return true
    case (.realEstateNumberOfBathrooms(let idA), .realEstateNumberOfBathrooms(let idB)) where idA == idB: return true
    case (.realEstatePropertyType(let idA), .realEstatePropertyType(let idB)) where idA == idB: return true
    case (.realEstateOfferType(let idA), .realEstateOfferType(let idB)) where idA == idB: return true
    case (.realEstateNumberOfRooms(let idA), .realEstateNumberOfRooms(let idB)) where idA == idB: return true
    case (.sizeSquareMetersRange(let a, let b), .sizeSquareMetersRange(let c, let d)) where a == c && b == d: return true
        
    default: return false
        
    }
}
