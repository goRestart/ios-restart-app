
public struct ServiceAttributes {
    
    public let typeId: String?
    public let subtypeId: String?
    public let typeTitle: String?
    public let subtypeTitle: String?
    public let paymentFrequency: PaymentFrequency?
    public let listingType: ServiceListingType?
    
    public init(typeId: String? = nil,
                subtypeId: String? = nil,
                listingType: ServiceListingType? = nil,
                typeTitle: String? = nil,
                subtypeTitle: String? = nil,
                paymentFrequency: PaymentFrequency? = nil) {
        self.typeId = typeId
        self.subtypeId = subtypeId
        self.listingType = listingType
        self.typeTitle = typeTitle
        self.subtypeTitle = subtypeTitle
        self.paymentFrequency = paymentFrequency
    }
    
    public func updating(typeId: String? = nil,
                         subtypeId: String? = nil,
                         listingType: ServiceListingType? = nil,
                         typeTitle: String? = nil,
                         subtypeTitle: String? = nil,
                         paymentFrequency: PaymentFrequency? = nil) -> ServiceAttributes {
        
        return ServiceAttributes(typeId: typeId ?? self.typeId,
                                 subtypeId: subtypeId ?? self.subtypeId,
                                 listingType: listingType ?? self.listingType,
                                 typeTitle: typeTitle ?? self.typeTitle,
                                 subtypeTitle: subtypeTitle ?? self.subtypeTitle,
                                 paymentFrequency: paymentFrequency ?? self.paymentFrequency)
    }
    
    public static func emptyServicesAttributes() -> ServiceAttributes {
        return ServiceAttributes()
    }
}

extension ServiceAttributes: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        typeId = try container.decodeIfPresent(String.self, forKey: .typeId)
        subtypeId = try container.decodeIfPresent(String.self, forKey: .subTypeId)
        
        if let listingTypeString = try container.decodeIfPresent(String.self, forKey: .listingType) {
            listingType = ServiceListingType(rawValue: listingTypeString)
        } else {
            listingType = nil
        }
        
        if let paymentFrequencyString = try container.decodeIfPresent(String.self, forKey: .paymentFrequency) {
            paymentFrequency = PaymentFrequency(rawValue: paymentFrequencyString)
        } else {
            paymentFrequency = nil
        }
        typeTitle = nil
        subtypeTitle = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeId, forKey: .typeId)
        try container.encode(subtypeId, forKey: .subTypeId)
        try container.encode(listingType?.rawValue, forKey: .listingType)
        try container.encode(paymentFrequency?.rawValue, forKey: .paymentFrequency)
    }
    
    enum CodingKeys: String, CodingKey {
        case typeId, subTypeId, listingType, paymentFrequency
    }
}

extension ServiceAttributes: Equatable { }
public func ==(lhs: ServiceAttributes, rhs: ServiceAttributes) -> Bool {
    return lhs.typeId == rhs.typeId &&
        lhs.subtypeId == rhs.subtypeId &&
        lhs.paymentFrequency == rhs.paymentFrequency &&
        lhs.listingType == rhs.listingType
}

