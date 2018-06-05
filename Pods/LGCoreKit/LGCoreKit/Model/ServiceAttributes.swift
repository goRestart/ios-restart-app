//  Copyright © 2018 Ambatana Inc. All rights reserved.

public struct ServiceAttributes {
    
    public let typeId: String?
    public let subtypeId: String?
    public let typeTitle: String?
    public let subtypeTitle: String?
    
    public init(typeId: String? = nil,
         subtypeId: String? = nil,
         typeTitle: String? = nil,
         subtypeTitle: String? = nil) {
        self.typeId = typeId
        self.subtypeId = subtypeId
        self.typeTitle = typeTitle
        self.subtypeTitle = subtypeTitle
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
        typeTitle = nil
        subtypeTitle = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeId, forKey: .typeId)
        try container.encode(subtypeId, forKey: .subTypeId)
    }
    
    enum CodingKeys: String, CodingKey {
        case typeId, subTypeId
    }
}

extension ServiceAttributes: Equatable { }
public func ==(lhs: ServiceAttributes, rhs: ServiceAttributes) -> Bool {
    return lhs.typeId == rhs.typeId && lhs.subtypeId == rhs.subtypeId
}

