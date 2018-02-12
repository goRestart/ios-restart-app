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
    var imageUrl: String? { get }
}


public struct LGSuggestedLocation: SuggestedLocation, Decodable {

    public let locationId: String
    public let locationName: String
    public let locationAddress: String?
    public let locationCoords: LGLocationCoordinates2D
    public let imageUrl: String?


    // MARK: Decode

    /*
     {
     "latitude": "41.246149579869",
     "longitude": "1.7950930443031",
     "location_id": "99458b70-807c-3780-83a9-47425e570489",
     "location_name": "paradis"
     "location_address": "Dumb street 123"
     "image_url": "http://location.whatever.com/lololo.jpg"
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)

        locationId = try keyedContainer.decode(String.self, forKey: .locationId)
        locationName = try keyedContainer.decode(String.self, forKey: .locationName)
        locationAddress = try keyedContainer.decodeIfPresent(String.self, forKey: .locationAddress)
        let latitude = try keyedContainer.decode(Double.self, forKey: .latitude)
        let longitude = try keyedContainer.decode(Double.self, forKey: .longitude)
        locationCoords = LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
        imageUrl = try keyedContainer.decodeIfPresent(String.self, forKey: .imageUrl)
    }

    enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
        case locationId = "location_id"
        case locationName = "location_name"
        case locationAddress = "location_address"
        case imageUrl = "image_url"
    }
}
