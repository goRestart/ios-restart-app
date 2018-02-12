//
//  FilterRealEstateSection.swift
//  LetGo
//
//  Created by Juan Iglesias on 07/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//


enum FilterRealEstateSection {
    case propertyType, offerTypeSale, offerTypeRent, numberOfRooms, numberOfBedrooms, numberOfBathrooms, sizeFrom, sizeTo
    
    static func allValues(postingFlowType: PostingFlowType) -> [FilterRealEstateSection] {
        switch postingFlowType {
        case .standard:
            return [.propertyType, .offerTypeSale, .offerTypeRent, .numberOfBedrooms, .numberOfBathrooms]
        case .turkish:
            return [.propertyType, .offerTypeSale, .offerTypeRent, .numberOfRooms, .sizeFrom, .sizeTo]
        }
    }
    
    func positionIn(allValues: [FilterRealEstateSection]) -> Int? {
        guard let position = allValues.index(where: {$0 == self }) else { return nil }
        return position
    }
}
