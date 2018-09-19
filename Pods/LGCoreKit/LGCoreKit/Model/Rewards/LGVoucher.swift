import Foundation

struct LGVoucher: Voucher {
    let id: String
    let createdAt: Date
    let countryCode: String
    let type: VoucherType
    let points: Int
    let itemId: String
}

extension LGVoucher: Decodable {
    
    /*
     {
     "type": "vouchers",
     "id": "xxx" // voucher id (unique for one purchase)
     "attributes": {
       "type":     "amazon_10"
       "points": 3
       "created_at": "1536851494000"
       "item_id": "xxx-xxx-xxx"
       "country_code": "CA"
     }
     */
    
    enum VoucherRootKeys: String, CodingKey {
        case type, id, attributes
    }
    
    enum VoucherAttributeKeys: String, CodingKey {
        case type, points, createdAt = "created_at", itemId = "item_id", countryCode = "country_code"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: VoucherRootKeys.self)
        id = try rootContainer.decode(String.self, forKey: .id)
        let attributesContainer = try rootContainer.nestedContainer(keyedBy: VoucherAttributeKeys.self, forKey: .attributes)
        type = try attributesContainer.decode(VoucherType.self, forKey: .type)
        let createdAtTimestamp = try attributesContainer.decode(TimeInterval.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: createdAtTimestamp.epochInSeconds())
        points = try attributesContainer.decode(Int.self, forKey: .points)
        countryCode = try attributesContainer.decode(String.self, forKey: .countryCode)
        itemId = try attributesContainer.decode(String.self, forKey: .itemId)
    }
}
