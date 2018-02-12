//
//  NumberOfRooms.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct NumberOfRooms {
    let numberOfBedrooms: Int
    let numberOfLivingRooms: Int
    
    var localizedString: String {
        if numberOfBedrooms == 1 && numberOfLivingRooms == 0 {
            return LGLocalizedString.realEstateRoomsStudio
        } else if numberOfBedrooms == 10 && numberOfLivingRooms == 0 {
            return LGLocalizedString.realEstateRoomsOverTen
        }
        return LGLocalizedString.realEstateRoomsValue(numberOfBedrooms, numberOfLivingRooms)
    }

    static var allValues: [NumberOfRooms] {
        return [NumberOfRooms(numberOfBedrooms: 1, numberOfLivingRooms: 0),
                NumberOfRooms(numberOfBedrooms: 1, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 2, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 2, numberOfLivingRooms: 2),
                NumberOfRooms(numberOfBedrooms: 3, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 3, numberOfLivingRooms: 2),
                NumberOfRooms(numberOfBedrooms: 4, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 4, numberOfLivingRooms: 2),
                NumberOfRooms(numberOfBedrooms: 4, numberOfLivingRooms: 3),
                NumberOfRooms(numberOfBedrooms: 4, numberOfLivingRooms: 4),
                NumberOfRooms(numberOfBedrooms: 5, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 5, numberOfLivingRooms: 2),
                NumberOfRooms(numberOfBedrooms: 5, numberOfLivingRooms: 3),
                NumberOfRooms(numberOfBedrooms: 5, numberOfLivingRooms: 4),
                NumberOfRooms(numberOfBedrooms: 6, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 6, numberOfLivingRooms: 2),
                NumberOfRooms(numberOfBedrooms: 6, numberOfLivingRooms: 3),
                NumberOfRooms(numberOfBedrooms: 7, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 7, numberOfLivingRooms: 2),
                NumberOfRooms(numberOfBedrooms: 7, numberOfLivingRooms: 3),
                NumberOfRooms(numberOfBedrooms: 8, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 8, numberOfLivingRooms: 2),
                NumberOfRooms(numberOfBedrooms: 8, numberOfLivingRooms: 3),
                NumberOfRooms(numberOfBedrooms: 8, numberOfLivingRooms: 4),
                NumberOfRooms(numberOfBedrooms: 9, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 9, numberOfLivingRooms: 2),
                NumberOfRooms(numberOfBedrooms: 9, numberOfLivingRooms: 3),
                NumberOfRooms(numberOfBedrooms: 9, numberOfLivingRooms: 4),
                NumberOfRooms(numberOfBedrooms: 9, numberOfLivingRooms: 5),
                NumberOfRooms(numberOfBedrooms: 9, numberOfLivingRooms: 6),
                NumberOfRooms(numberOfBedrooms: 10, numberOfLivingRooms: 1),
                NumberOfRooms(numberOfBedrooms: 10, numberOfLivingRooms: 2),
                NumberOfRooms(numberOfBedrooms: 10, numberOfLivingRooms: 0)]
    }
    
    func positionIn(allValues: [NumberOfRooms]) -> Int? {
        guard let position = allValues.index(where: {$0 == self }) else { return nil }
        return position
    }
}

func ==(lhs: NumberOfRooms?, rhs: NumberOfRooms?) -> Bool {
    guard let lhs = lhs else {
        guard let _ = rhs else { return true }
        return false
    }
    guard let rhs = rhs else { return false }
    return lhs.numberOfBedrooms == rhs.numberOfBedrooms && lhs.numberOfLivingRooms == rhs.numberOfLivingRooms
}
