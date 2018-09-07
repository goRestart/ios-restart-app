
struct LGFeedItemGeoData {
    
    let location: LGLocationCoordinates2D
    let countryCode: String?
    let city: String?
    let zipCode: String?
}

extension LGFeedItemGeoData: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case coords, countryCode = "country_code", city, zipCode = "zip_code"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        location = LGFeedLocation
            .toLGLocationCoordinates2D(location: try container.decode(LGFeedLocation.self, forKey: .coords))
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        zipCode = try container.decodeIfPresent(String.self, forKey: .zipCode)
    }
}

extension LGFeedItemGeoData {
    
    static func toPostalAddress(geodata: LGFeedItemGeoData?) -> PostalAddress {
        guard
            let city = geodata?.city,
            let zipCode = geodata?.zipCode,
            let countryCode = geodata?.countryCode else {
                return PostalAddress.emptyAddress()
        }
        return PostalAddress(address: nil,
                             city: city,
                             zipCode: zipCode,
                             state: nil,
                             countryCode: countryCode,
                             country: nil)
    }
}

/// We want to be able to have an optional location for Owner but not for Item, that's why we duplicate GeoData
struct LGFeedOwnerGeoData {

    let location: LGLocationCoordinates2D?
    let countryCode: String?
    let city: String?
    let zipCode: String?
}

extension LGFeedOwnerGeoData: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case coords, countryCode = "country_code", city, zipCode = "zip_code"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let coords = try container.decodeIfPresent(LGFeedLocation.self, forKey: .coords) {
            location = LGFeedLocation.toLGLocationCoordinates2D(location: coords)
        } else {
            location = nil
        }
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        zipCode = try container.decodeIfPresent(String.self, forKey: .zipCode)
    }
}

extension LGFeedOwnerGeoData {
    
    static func toPostalAddress(city: String?, zipCode: String?, countryCode: String?) -> PostalAddress {
        guard let city = city,
            let zipCode = zipCode,
            let countryCode = countryCode else {
                return PostalAddress.emptyAddress()
        }
        return PostalAddress(address: nil,
                             city: city,
                             zipCode: zipCode,
                             state: nil,
                             countryCode: countryCode,
                             country: nil)
    }
}

