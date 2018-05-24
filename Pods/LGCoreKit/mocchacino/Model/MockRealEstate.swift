public struct MockRealEstate: RealEstate {
    public var objectId: String?
    public var name: String?
    public var nameAuto: String?
    public var descr: String?
    public var price: ListingPrice
    public var currency: Currency
    public var location: LGLocationCoordinates2D
    public var postalAddress: PostalAddress
    public var languageCode: String?
    public var category: ListingCategory
    public var status: ListingStatus
    public var thumbnail: File?
    public var thumbnailSize: LGSize?
    public var images: [File]
    public var media: [Media]
    public var mediaThumbnail: MediaThumbnail?
    public var user: UserListing
    public var updatedAt : Date?
    public var createdAt : Date?
    public var featured: Bool?
    public var realEstateAttributes: RealEstateAttributes
}

extension MockRealEstate {
    public init(realEstate: RealEstate) {
        self.init(objectId: realEstate.objectId,
                  name: realEstate.name,
                  nameAuto: realEstate.nameAuto,
                  descr: realEstate.descr,
                  price: realEstate.price,
                  currency: realEstate.currency,
                  location: realEstate.location,
                  postalAddress: realEstate.postalAddress,
                  languageCode: realEstate.languageCode,
                  category: realEstate.category,
                  status: realEstate.status,
                  thumbnail: realEstate.thumbnail,
                  thumbnailSize: realEstate.thumbnailSize,
                  images: realEstate.images,
                  media: realEstate.media,
                  mediaThumbnail: realEstate.mediaThumbnail,
                  user: realEstate.user,
                  updatedAt: realEstate.updatedAt,
                  createdAt: realEstate.createdAt,
                  featured: realEstate.featured,
                  realEstateAttributes: realEstate.realEstateAttributes)
    }
}
