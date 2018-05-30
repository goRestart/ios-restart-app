//  Copyright © 2018 Ambatana Inc. All rights reserved.

public struct MockService: Service {
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
    public var servicesAttributes: ServiceAttributes
    public func updating(servicesAttributes: ServiceAttributes) -> Service  {
        var service = MockService(service: self)
        service.servicesAttributes = servicesAttributes
        return service
    }
}

extension MockService {
    public init(service: Service) {
        self.init(objectId: service.objectId,
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
                  updatedAt: service.updatedAt,
                  createdAt: service.createdAt,
                  featured: service.featured,
                  servicesAttributes: service.servicesAttributes)
    }
}
