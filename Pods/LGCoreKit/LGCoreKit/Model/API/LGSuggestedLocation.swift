//
//  LGSuggestedLocation.swift
//  LGCoreKit
//
//  Created by Dídac on 09/02/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol SuggestedLocation {
    var locationId: String { get }
    var locationName: String { get }
    var locationAddress: String? { get }
    var locationCoords: LGLocationCoordinates2D { get }
}


public struct LGSuggestedLocation: SuggestedLocation, Decodable {

    public let locationId: String
    public let locationName: String
    public let locationAddress: String?
    public let locationCoords: LGLocationCoordinates2D


    // MARK: Decode

    /*
     {
     "latitude": "41.246149579869",
     "longitude": "1.7950930443031",
     "location_id": "99458b70-807c-3780-83a9-47425e570489",
     "location_name": "paradis"
     "address": "Dumb street 123"
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)

        locationId = try keyedContainer.decode(String.self, forKey: .locationId)
        locationName = try keyedContainer.decode(String.self, forKey: .locationName)
        locationAddress = try keyedContainer.decodeIfPresent(String.self, forKey: .locationAddress)
        let stringLatitude = try keyedContainer.decode(String.self, forKey: .latitude)
        let stringLongitude = try keyedContainer.decode(String.self, forKey: .longitude)

        let doubleLatitude = Double(stringLatitude) ?? 0.0
        let doubleLongitude = Double(stringLongitude) ?? 0.0

        locationCoords = LGLocationCoordinates2D(latitude: doubleLatitude, longitude: doubleLongitude)
    }

    enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
        case locationId = "location_id"
        case locationName = "location_name"
        case locationAddress = "address"
    }
}
