
struct LGFeedItemOwner: Decodable {
    
    let id: String
    let name: String?
    let avatarUrl: URL?
    let countryCode: String?
    let city: String?
    let zipCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, avatarUrl = "avatar_url", countryCode = "country_code", city, zipCode = "zip_code"
    }
}

extension LGFeedItemOwner {
    
    static func toUserListing(owner: LGFeedItemOwner) -> LGUserListing {
        let postalAddress = LGFeedOwnerGeoData.toPostalAddress(city: owner.city,
                                                               zipCode: owner.zipCode,
                                                               countryCode: owner.countryCode)
        return LGUserListing(objectId: owner.id,
                             name: owner.name,
                             avatar: owner.avatarUrl?.absoluteString,
                             postalAddress: postalAddress,
                             isDummy: false,
                             banned: false,
                             status: UserStatus.active,
                             type: UserType.user)
    }
}
