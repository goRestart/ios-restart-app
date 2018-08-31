
/// Model that maps the item json structure used in the section feed response
struct LGFeedProduct {
    
    struct LGAutogeneratedTitle: Decodable {
        let text: String
        let isTranslated: Bool
        
        enum CodingKeys: String, CodingKey {
            case text, isTranslated = "is_translated"
        }
    }
    
    let id: String
    let category: ListingCategory
    let name: String?
    let description: String?
    let autogeneratedTitle: LGAutogeneratedTitle?
    let featured: Bool
    let createdAt: Date?
    let updatedAt: Date?
    let owner: LGFeedItemOwner
    let geoData: LGFeedItemGeoData?
    let price: LGFeedItemPrice
    let media: LGFeedMedia
}

extension LGFeedProduct: Decodable {
    
    /*
     {
     "id": "g4IyuicLYj",
     "created_at": "2018-07-09T09:14:37Z",
     "updated_at": "2018-07-09T09:14:37Z",
     "category_id": 2,
     "name": "cancamusa",
     "description": "bright cancamusa with just one use",
     "autogenerated_title": {
       "text": "blue box with a handle",
       "is_translated": false
     },
     "owner": {
        "id": "abdcd",
        "name": "John Smith",
        "avatar_url": "https://avatar/molon.jpg",
        "zip_code": "EH6 8QP",
        "country_code": "US",
        "city": "Edimburgh"
     },
     "geo_data": {
       "coords": {
         "latitude": 34,
         "longitude": -3
       },
       "country_code": "US",
       "city": "Stirling",
       "zip_code": "EH2 KK3"
     },
     "price": {
       "amount": 12.5,
       "currency": "USD",
       "flag": "normal"
     },
     "featured": false,
     "media": {
          "thumbnail": {
            "type": "video",
            "url": "https://img.letgo.com/images/dd/a2/af/07/dd92.jpeg?impolicy=img_200",
            "width": 200,
            "height": 300
          },
          "items": [
            {
              "image": {
                "id": "dd92",
                "url": "https://img.letgo.com/images/dd/a2/af/07/dd92.jpeg"
              }
            },
            {
              "image": {
                "id": "foo",
                "url": "https://img.letgo.com/images/dd/a2/af/07/foo.jpeg"
              },
              "video": {
                "id": "bar",
                "url": "https://img.letgo.com/images/dd/a2/af/07/bar.mpg"
              },
              "video_thumb": {
                "id": "buzz",
                "url": "https://img.letgo.com/images/dd/a2/af/07/buzz.gif"
              }
            }
          ]
        }
     }
     */
    
    enum CodingKeys: String, CodingKey {
        case id, category = "category_id", name, description, autogeneratedTitle = "autogenerated_title", featured,
        createdAt = "created_at", updatedAt = "updated_at", owner, geoData = "geo_data", price, media
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        category = ListingCategory(rawValue: try container.decode(Int.self, forKey: .category)) ?? .unassigned
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        autogeneratedTitle = try container.decodeIfPresent(LGAutogeneratedTitle.self, forKey: .autogeneratedTitle)
        featured = try container.decodeIfPresent(Bool.self, forKey: .featured) ?? false
        createdAt = Core.dateFormatter.date(from: try container.decode(String.self, forKey: .createdAt))
        updatedAt = Core.dateFormatter.date(from: try container.decode(String.self, forKey: .updatedAt))
        owner = try container.decode(LGFeedItemOwner.self, forKey: .owner)
        geoData = try container.decodeIfPresent(LGFeedItemGeoData.self, forKey: .geoData)
        price = try container.decode(LGFeedItemPrice.self, forKey: .price)
        media = try container.decode(LGFeedMedia.self, forKey: .media)
    }
}

extension LGFeedProduct {
    
    static func toMediaThumbnail(item: LGFeedProduct) -> LGMediaThumbnail? {
        guard
            let file = LGFeedMediaThumbnail.toFile(thumb: item.media.thumbnail),
            let type = item.media.thumbnail?.type,
            let size = LGFeedMediaThumbnail.toLGSize(thumb: item.media.thumbnail) else {
                return nil
        }
        return LGMediaThumbnail( file: file, type: type, size: size)
    }
    
    static func toListing(item: LGFeedProduct) -> Listing? {
        guard let baseListing = LGFeedProduct.toBaseListing(item: item) else { return nil }
        switch item.category {
        case .unassigned, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden,
             .moviesBooksAndMusic, .fashionAndAccesories, .babyAndChild, .other:
            return Listing.product(LGProduct(baseListing: baseListing))
        case .cars:
            return Listing.car(LGCar(baseListing: baseListing, attributes: nil))
        case .realEstate:
            return Listing.realEstate(LGRealEstate(baseListing: baseListing, attributes: nil))
        case .services:
            return Listing.service(LGService(baseListing: baseListing, attributes: nil))
        }
    }
    
    private static func toBaseListing(item: LGFeedProduct) -> LGBaseListing? {
        guard let geoData = item.geoData else { return nil }
        let baseListing = LGBaseListing(
            objectId: item.id,
            updatedAt: item.updatedAt,
            createdAt: item.createdAt,
            name: item.name,
            nameAuto: item.autogeneratedTitle?.text,
            descr: item.description,
            price: LGFeedItemPrice.toListingPrice(price: item.price),
            currency: Core.currencyHelper.currencyWithCurrencyCode(item.price.currency),
            location: geoData.location,
            postalAddress: LGFeedItemGeoData.toPostalAddress(geodata: item.geoData),
            languageCode: nil,
            category: item.category,
            status: .approved,
            thumbnail: LGFeedMediaThumbnail.toFile(thumb: item.media.thumbnail),
            thumbnailSize: LGFeedMediaThumbnail.toLGSize(thumb: item.media.thumbnail),
            images: item.media.items.compactMap(LGFeedMediaItem.toFile),
            media: item.media.items.map({LGFeedMediaItem.toMedia(mediaItem: $0, imageThumbnail: item.media.thumbnail?.url)}),
            mediaThumbnail: LGFeedProduct.toMediaThumbnail(item: item),
            user: LGFeedItemOwner.toUserListing(owner: item.owner),
            featured: item.featured,
            carAttributes: nil)
        return baseListing
    }
}
