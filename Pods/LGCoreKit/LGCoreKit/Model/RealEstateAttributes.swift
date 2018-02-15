//
//  RealEstateAttributes.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 05/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public enum RealEstateOfferType: String {
    case rent = "rent"
    case sale = "sale"
}

public enum RealEstatePropertyType: String {
    case apartment = "apartment"
    case house = "house"
    case room = "room"
    case commercial = "commercial"
    case other = "others"
    
    case flat = "flat"
    case villa = "villa"
    case land = "land"
}

public struct RealEstateAttributes: Equatable {
    public let propertyType: RealEstatePropertyType?
    public let offerType: RealEstateOfferType?
    public let bedrooms: Int?
    public let bathrooms: Float?
    public let livingRooms: Int?
    public let sizeSquareMeters: Int?
    
    public init(propertyType: RealEstatePropertyType?,
                offerType: RealEstateOfferType?,
                bedrooms: Int?,
                bathrooms: Float?,
                livingRooms: Int?,
                sizeSquareMeters: Int?) {
        self.propertyType = propertyType
        self.offerType = offerType
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.livingRooms = livingRooms
        self.sizeSquareMeters = sizeSquareMeters
    }
    public static func make(propertyType: String?,
                            offerType: String?,
                            bedrooms: Int?,
                            bathrooms: Float?,
                            livingRooms: Int?,
                            sizeSquareMeters: Int?) -> RealEstateAttributes {
        let newPropertyType = RealEstatePropertyType(rawValue: propertyType ?? "")
        let offerType = RealEstateOfferType(rawValue: offerType ?? "")
        return self.init(propertyType: newPropertyType,
                         offerType: offerType,
                         bedrooms: bedrooms,
                         bathrooms: bathrooms,
                         livingRooms: livingRooms,
                         sizeSquareMeters: sizeSquareMeters)
    }
    
    public static func emptyRealEstateAttributes() -> RealEstateAttributes {
        return RealEstateAttributes(propertyType: nil,
                                    offerType: nil,
                                    bedrooms: nil,
                                    bathrooms: nil,
                                    livingRooms: nil,
                                    sizeSquareMeters: nil)
    }
    
    public func updating(propertyType: RealEstatePropertyType? = nil,
                         offerType: RealEstateOfferType? = nil,
                         bedrooms: Int? = nil,
                         bathrooms: Float? = nil,
                         livingRooms: Int? = nil,
                         sizeSquareMeters: Int? = nil) -> RealEstateAttributes {
        
        return RealEstateAttributes(propertyType: propertyType ?? self.propertyType,
                                    offerType: offerType ?? self.offerType,
                                    bedrooms: bedrooms ?? self.bedrooms,
                                    bathrooms: bathrooms ?? self.bathrooms,
                                    livingRooms: livingRooms ?? self.livingRooms,
                                    sizeSquareMeters: sizeSquareMeters ?? self.sizeSquareMeters)
    }
    
    public func removing(propertyType: Bool = false,
                         offerType: Bool = false,
                         bedrooms: Bool = false,
                         bathrooms: Bool = false,
                         livingRooms: Bool = false,
                         sizeSquareMeters: Bool = false) -> RealEstateAttributes {
        
        return RealEstateAttributes(propertyType: propertyType ? nil : self.propertyType,
                                    offerType: offerType ? nil : self.offerType,
                                    bedrooms: bedrooms ? nil : self.bedrooms,
                                    bathrooms: bathrooms ? nil : self.bathrooms,
                                    livingRooms: livingRooms ? nil : self.livingRooms,
                                    sizeSquareMeters: sizeSquareMeters ? nil : self.sizeSquareMeters)
    }
}

public func ==(lhs: RealEstateAttributes, rhs: RealEstateAttributes) -> Bool {
    return lhs.propertyType == rhs.propertyType && lhs.offerType == rhs.offerType &&
        lhs.bedrooms == rhs.bedrooms && lhs.bathrooms == rhs.bathrooms &&
        lhs.livingRooms == rhs.livingRooms && lhs.sizeSquareMeters == rhs.sizeSquareMeters
}

extension RealEstateAttributes: Decodable {
    
    // MARK: Decodable
    
    /*
     {
     "typeOfProperty": "room",
     "typeOfListing": "rent",
     "numberOfBedrooms": 1,
     "numberOfBathrooms": 2,
     "numberOfLivingRooms": 2,
     "sizeSquareMeters": 100
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        if let propertyTypeDecoded = try keyedContainer.decodeIfPresent(String.self, forKey: .typeOfProperty),
            let propertyType = RealEstatePropertyType(rawValue: propertyTypeDecoded) {
            self.propertyType = propertyType
        } else {
            propertyType = nil
        }
        if let offerTypeDecoded = try keyedContainer.decodeIfPresent(String.self, forKey: .typeOfListing),
            let offerType = RealEstateOfferType(rawValue: offerTypeDecoded) {
            self.offerType = offerType
        } else {
            offerType = nil
        }
        bedrooms = try keyedContainer.decodeIfPresent(Int.self, forKey: .numberOfBedrooms)
        bathrooms = try keyedContainer.decodeIfPresent(Float.self, forKey: .numberOfBathrooms)
        livingRooms = try keyedContainer.decodeIfPresent(Int.self, forKey: .numberOfLivingRooms)
        sizeSquareMeters = try keyedContainer.decodeIfPresent(Int.self, forKey: .sizeSquareMeters)
    }
    
    enum CodingKeys: String, CodingKey {
        case typeOfProperty
        case typeOfListing
        case numberOfBedrooms
        case numberOfBathrooms
        case numberOfLivingRooms
        case sizeSquareMeters
    }
}
