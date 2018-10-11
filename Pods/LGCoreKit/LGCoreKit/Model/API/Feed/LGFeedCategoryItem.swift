/// Model that maps the FeedCategoryItem json structure used in the section feed response
struct LGFeedCategoryItem {
    let listingCategory: ListingCategory
}

extension LGFeedCategoryItem: Decodable {
    /*
     {
        "category_id": 9
     }
     */
    
    enum CodingKeys: String, CodingKey {
        case category = "category_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        listingCategory = ListingCategory(rawValue: try container.decode(Int.self, forKey: .category)) ?? .unassigned
    }
}


