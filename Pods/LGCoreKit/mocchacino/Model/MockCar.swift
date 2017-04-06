public struct MockCar: Car {
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
    public var user: UserListing
    public var updatedAt : Date?
    public var createdAt : Date?
    public var featured: Bool?
    public var favorite: Bool
    public var make: String?
    public var makeId: String?
    public var model: String?
    public var modelId: String?
    public var year: Int?
}

extension MockCar {
    public init(car: Car) {
        self.init(objectId: car.objectId,
                  name: car.name,
                  nameAuto: car.nameAuto,
                  descr: car.descr,
                  price: car.price,
                  currency: car.currency,
                  location: car.location,
                  postalAddress: car.postalAddress,
                  languageCode: car.languageCode,
                  category: car.category,
                  status: car.status,
                  thumbnail: car.thumbnail,
                  thumbnailSize: car.thumbnailSize,
                  images: car.images,
                  user: car.user,
                  updatedAt: car.updatedAt,
                  createdAt: car.createdAt,
                  featured: car.featured,
                  favorite: car.favorite,
                  make: car.make,
                  makeId: car.makeId,
                  model: car.model,
                  modelId: car.modelId,
                  year: car.year)
    }
}
