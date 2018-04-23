public struct MockProduct: Product {
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
}

extension MockProduct {
    public init(product: Product) {
        self.init(objectId: product.objectId,
                  name: product.name,
                  nameAuto: product.nameAuto,
                  descr: product.descr,
                  price: product.price,
                  currency: product.currency,
                  location: product.location,
                  postalAddress: product.postalAddress,
                  languageCode: product.languageCode,
                  category: product.category,
                  status: product.status,
                  thumbnail: product.thumbnail,
                  thumbnailSize: product.thumbnailSize,
                  images: product.images,
                  media: product.media,
                  mediaThumbnail: product.mediaThumbnail,
                  user: product.user,
                  updatedAt: product.updatedAt,
                  createdAt: product.createdAt,
                  featured: product.featured
                  )
    }
}
