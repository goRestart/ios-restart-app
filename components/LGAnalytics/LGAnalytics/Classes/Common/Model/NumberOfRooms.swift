//
//  NumberOfRooms.swift
//  LGAnalytics
//
//  Created by Albert Hernández López on 29/03/2018.
//

public struct NumberOfRooms {
    let numberOfBedrooms: Int
    let numberOfLivingRooms: Int

    var trackingString: String {
        if numberOfBedrooms == 1 && numberOfLivingRooms == 0 {
            return "Studio (1+0)"
        } else if numberOfBedrooms == 10 && numberOfLivingRooms == 0 {
            return "Over 10"
        }
        return "\(numberOfBedrooms)+\(numberOfLivingRooms)"
    }
}
