//
//  NumberOfRooms.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct NumberOfRooms {
    let bedrooms: Int?
    let livingRooms: Int?
    
    var localizedString: String? {
        if let bedrooms = bedrooms, bedrooms == 1, let livingRooms = livingRooms, livingRooms == 0 {
            return LGLocalizedString.realEstateRoomsStudio
        } else if bedrooms == 10 && livingRooms == 0 {
            return LGLocalizedString.realEstateRoomsOverTen
        }
        guard let bedrooms = bedrooms, let livingRooms = livingRooms else { return nil }
        return LGLocalizedString.realEstateRoomsValue(bedrooms, livingRooms)
    }

    static var allValues: [NumberOfRooms] {
        return [NumberOfRooms(bedrooms: 1, livingRooms: 0),
                NumberOfRooms(bedrooms: 1, livingRooms: 1),
                NumberOfRooms(bedrooms: 2, livingRooms: 1),
                NumberOfRooms(bedrooms: 2, livingRooms: 2),
                NumberOfRooms(bedrooms: 3, livingRooms: 1),
                NumberOfRooms(bedrooms: 3, livingRooms: 2),
                NumberOfRooms(bedrooms: 4, livingRooms: 1),
                NumberOfRooms(bedrooms: 4, livingRooms: 2),
                NumberOfRooms(bedrooms: 4, livingRooms: 3),
                NumberOfRooms(bedrooms: 4, livingRooms: 4),
                NumberOfRooms(bedrooms: 5, livingRooms: 1),
                NumberOfRooms(bedrooms: 5, livingRooms: 2),
                NumberOfRooms(bedrooms: 5, livingRooms: 3),
                NumberOfRooms(bedrooms: 5, livingRooms: 4),
                NumberOfRooms(bedrooms: 6, livingRooms: 1),
                NumberOfRooms(bedrooms: 6, livingRooms: 2),
                NumberOfRooms(bedrooms: 6, livingRooms: 3),
                NumberOfRooms(bedrooms: 7, livingRooms: 1),
                NumberOfRooms(bedrooms: 7, livingRooms: 2),
                NumberOfRooms(bedrooms: 7, livingRooms: 3),
                NumberOfRooms(bedrooms: 8, livingRooms: 1),
                NumberOfRooms(bedrooms: 8, livingRooms: 2),
                NumberOfRooms(bedrooms: 8, livingRooms: 3),
                NumberOfRooms(bedrooms: 8, livingRooms: 4),
                NumberOfRooms(bedrooms: 9, livingRooms: 1),
                NumberOfRooms(bedrooms: 9, livingRooms: 2),
                NumberOfRooms(bedrooms: 9, livingRooms: 3),
                NumberOfRooms(bedrooms: 9, livingRooms: 4),
                NumberOfRooms(bedrooms: 9, livingRooms: 5),
                NumberOfRooms(bedrooms: 9, livingRooms: 6),
                NumberOfRooms(bedrooms: 10, livingRooms: 1),
                NumberOfRooms(bedrooms: 10, livingRooms: 2),
                NumberOfRooms(bedrooms: 10, livingRooms: 0)]
    }
}
