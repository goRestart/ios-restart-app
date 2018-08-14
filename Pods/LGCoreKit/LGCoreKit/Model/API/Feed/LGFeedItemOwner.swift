
struct LGFeedItemOwner: Decodable {
    
    let id: String
    let name: String?
    let avatarUrl: URL?
    let geoData: LGFeedOwnerGeoData?
    
    enum CodingKeys: String, CodingKey {
        case id, name, avatarUrl = "avatar_url", geoData = "geo_data"
    }
}

extension LGFeedItemOwner {
    
    static func toUserListing(owner: LGFeedItemOwner) -> LGUserListing {
        return LGUserListing(objectId: owner.id,
                             name: owner.name,
                             avatar: owner.avatarUrl?.absoluteString,
                             postalAddress: LGFeedOwnerGeoData.toPostalAddress(geodata: owner.geoData),
                             isDummy: false,
                             banned: false,
                             status: UserStatus.active,
                             type: UserType.user)
    }
}
