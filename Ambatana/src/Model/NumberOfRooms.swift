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
            return "Studio"
        } else if let bedrooms = bedrooms, bedrooms == 10 && livingRooms == nil {
            return "Over 10"
        }
        guard let bedrooms = bedrooms, let livingRooms = livingRooms else { return nil }
        return "\(bedrooms)" + "+" + "\(livingRooms)"
    }

    static func allValues() -> [Rooms] {
        return [Rooms(bedrooms: 1, livingRooms: 0),
                Rooms(bedrooms: 1, livingRooms: 1),
                Rooms(bedrooms: 2, livingRooms: 1),
                Rooms(bedrooms: 2, livingRooms: 2),
                Rooms(bedrooms: 3, livingRooms: 1),
                Rooms(bedrooms: 3, livingRooms: 2),
                Rooms(bedrooms: 4, livingRooms: 1),
                Rooms(bedrooms: 4, livingRooms: 2),
                Rooms(bedrooms: 4, livingRooms: 3),
                Rooms(bedrooms: 4, livingRooms: 4),
                Rooms(bedrooms: 5, livingRooms: 1),
                Rooms(bedrooms: 5, livingRooms: 2),
                Rooms(bedrooms: 5, livingRooms: 3),
                Rooms(bedrooms: 5, livingRooms: 4),
                Rooms(bedrooms: 6, livingRooms: 1),
                Rooms(bedrooms: 6, livingRooms: 2),
                Rooms(bedrooms: 6, livingRooms: 3),
                Rooms(bedrooms: 7, livingRooms: 1),
                Rooms(bedrooms: 7, livingRooms: 2),
                Rooms(bedrooms: 7, livingRooms: 3),
                Rooms(bedrooms: 8, livingRooms: 1),
                Rooms(bedrooms: 8, livingRooms: 2),
                Rooms(bedrooms: 8, livingRooms: 3),
                Rooms(bedrooms: 8, livingRooms: 4),
                Rooms(bedrooms: 9, livingRooms: 1),
                Rooms(bedrooms: 9, livingRooms: 2),
                Rooms(bedrooms: 9, livingRooms: 3),
                Rooms(bedrooms: 9, livingRooms: 4),
                Rooms(bedrooms: 9, livingRooms: 5),
                Rooms(bedrooms: 9, livingRooms: 6),
                Rooms(bedrooms: 10, livingRooms: 1),
                Rooms(bedrooms: 10, livingRooms: 2),
                Rooms(bedrooms: 10, livingRooms: nil)]
    }
}
