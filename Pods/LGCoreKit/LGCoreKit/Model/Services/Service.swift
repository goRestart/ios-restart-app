public protocol Service: BaseListingModel {
    var servicesAttributes: ServiceAttributes { get }
    func updating(servicesAttributes: ServiceAttributes) -> Service
}

struct LGService: Service {
    let objectId: String?
    let updatedAt: Date?
    let createdAt: Date?
    let name: String?
    let nameAuto: String?
    let descr: String?
    let price: ListingPrice
    let currency: Currency
    let location: LGLocationCoordinates2D
    let postalAddress: PostalAddress
    let languageCode: String?
    let category: ListingCategory
    let status: ListingStatus
    let thumbnail: File?
    let thumbnailSize: LGSize?
    let images: [File]
    var media: [Media]
    var mediaThumbnail: MediaThumbnail?
    var user: UserListing
    let featured: Bool?
    let servicesAttributes: ServiceAttributes
    
    init(service: Service) {
        self.init(objectId: service.objectId,
                  updatedAt: service.updatedAt,
                  createdAt: service.createdAt,
                  name: service.name,
                  nameAuto: service.nameAuto,
                  descr: service.descr,
                  price: service.price,
                  currency: service.currency,
                  location: service.location,
                  postalAddress: service.postalAddress,
                  languageCode: service.languageCode,
                  category: service.category,
                  status: service.status,
                  thumbnail: service.thumbnail,
                  thumbnailSize: service.thumbnailSize,
                  images: service.images,
                  media: service.media,
                  mediaThumbnail: service.mediaThumbnail,
                  user: service.user,
                  featured: service.featured,
                  servicesAttributes: service.servicesAttributes)
    }
    
    init(objectId: String?,
         updatedAt: Date?,
         createdAt: Date?,
         name: String?,
         nameAuto: String?,
         descr: String?,
         price: ListingPrice,
         currency: Currency,
         location: LGLocationCoordinates2D,
         postalAddress: PostalAddress,
         languageCode: String?,
         category: ListingCategory,
         status: ListingStatus,
         thumbnail: File?,
         thumbnailSize: LGSize?,
         images: [File],
         media: [Media],
         mediaThumbnail: MediaThumbnail?,
         user: UserListing,
         featured: Bool?,
         servicesAttributes: ServiceAttributes?) {
        
        self.objectId = objectId
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.name = name
        self.nameAuto = nameAuto
        self.descr = descr
        self.price = price
        self.currency = currency
        self.location = location
        self.postalAddress = postalAddress
        self.languageCode = languageCode
        self.category = category
        self.status = status
        self.thumbnail = thumbnail
        self.thumbnailSize = thumbnailSize
        self.images = images
        self.media = media
        self.mediaThumbnail = mediaThumbnail
        self.user = user
        self.featured = featured ?? false
        self.servicesAttributes = servicesAttributes ?? ServiceAttributes.emptyServicesAttributes()
    }
    
    func updating(category: ListingCategory) -> LGService {
        return LGService(objectId: objectId,
                         updatedAt: updatedAt,
                         createdAt: createdAt,
                         name: name,
                         nameAuto: nameAuto,
                         descr: descr,
                         price: price,
                         currency: currency,
                         location: location,
                         postalAddress: postalAddress,
                         languageCode: languageCode,
                         category: category,
                         status: status,
                         thumbnail: thumbnail,
                         thumbnailSize: thumbnailSize,
                         images: images,
                         media: media,
                         mediaThumbnail: mediaThumbnail,
                         user: user,
                         featured: featured,
                         servicesAttributes: servicesAttributes)
    }
    
    func updating(status: ListingStatus) -> LGService {
        return LGService(objectId: objectId,
                            updatedAt: updatedAt,
                            createdAt: createdAt,
                            name: name,
                            nameAuto: nameAuto,
                            descr: descr,
                            price: price,
                            currency: currency,
                            location: location,
                            postalAddress: postalAddress,
                            languageCode: languageCode,
                            category: category,
                            status: status,
                            thumbnail: thumbnail,
                            thumbnailSize: thumbnailSize,
                            images: images,
                            media: media,
                            mediaThumbnail: mediaThumbnail,
                            user: user,
                            featured: featured,
                            servicesAttributes: servicesAttributes)
    }
    
    func updating(servicesAttributes: ServiceAttributes) -> Service {
        return LGService(objectId: objectId,
                         updatedAt: updatedAt,
                         createdAt: createdAt,
                         name: name,
                         nameAuto: nameAuto,
                         descr: descr,
                         price: price,
                         currency: currency,
                         location: location,
                         postalAddress: postalAddress,
                         languageCode: languageCode,
                         category: category,
                         status: status,
                         thumbnail: thumbnail,
                         thumbnailSize: thumbnailSize,
                         images: images,
                         media: media,
                         mediaThumbnail: mediaThumbnail,
                         user: user,
                         featured: featured,
                         servicesAttributes: servicesAttributes)
    }
    
}

extension LGService: Codable {
    
    public init(from decoder: Decoder) throws {
        let baseListing = try LGBaseListing(from: decoder)
        objectId = baseListing.objectId
        updatedAt = baseListing.updatedAt
        createdAt = baseListing.createdAt
        name = baseListing.name
        nameAuto = baseListing.nameAuto
        descr = baseListing.descr
        price = baseListing.price
        currency = baseListing.currency
        location = baseListing.location
        postalAddress = baseListing.postalAddress
        languageCode = baseListing.languageCode
        category = baseListing.category
        status = baseListing.status
        thumbnail = baseListing.thumbnail
        thumbnailSize = baseListing.thumbnailSize
        images = baseListing.images
        media = baseListing.media.isEmpty ? LGMedia.mediaFrom(images: baseListing.images) : baseListing.media
        mediaThumbnail = baseListing.mediaThumbnail
        user = baseListing.user
        featured = baseListing.featured
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let searchContainer = try decoder.container(keyedBy: SerchApiCodingKeys.self)
        if let attributes =  try container.decodeIfPresent(ServiceAttributes.self, forKey: .serviceAttributes) {
            servicesAttributes = attributes
        } else {
            servicesAttributes = try searchContainer.decodeIfPresent(ServiceAttributes.self, forKey: .attributes)
                ?? ServiceAttributes.emptyServicesAttributes()
        }
    }

    public func encode(to encoder: Encoder) throws {
        let baseListing = LGBaseListing(objectId: objectId,
                                        updatedAt: updatedAt,
                                        createdAt: createdAt,
                                        name: name,
                                        nameAuto: nameAuto,
                                        descr: descr,
                                        price: price,
                                        currency: currency,
                                        location: location,
                                        postalAddress: postalAddress,
                                        languageCode: languageCode,
                                        category: category,
                                        status: status,
                                        thumbnail: thumbnail,
                                        thumbnailSize: thumbnailSize,
                                        images: images,
                                        media: media,
                                        mediaThumbnail: mediaThumbnail,
                                        user: user,
                                        featured: featured,
                                        carAttributes: nil)
        // We don't sync services attributes on purpose, we can sync them again later
        try baseListing.encode(to: encoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case serviceAttributes
    }
    enum SerchApiCodingKeys: String, CodingKey {
        case attributes
    }
}
