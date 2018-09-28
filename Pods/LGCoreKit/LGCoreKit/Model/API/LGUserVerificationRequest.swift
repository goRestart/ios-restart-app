import Foundation

/**
 {
     "type":"verification-requests",
     "attributes":{
        "status": "requested"
     },
     "relationships": {
         "requester": {
            "data": { "type": "users", "id": "5c946af2-aed6-4712-8c6d-4d6576992981" }
         },
         "requested": {
            "data": { "type": "users", "id": "54d661f5-4c4b-4aac-8d93-7956788fb82a" }
         }
     }
 }
 */

struct LGUserVerificationRequest: UserVerificationRequest, Decodable, Encodable {
    let requesterUserId: String
    let requestedUserId: String
    let status: UserVerificationRequestStatus

    public init(from decoder: Decoder) throws {
        let dataValues = try decoder.container(keyedBy: DataKeys.self)

        let attributes = try dataValues.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        let statusString = try attributes.decode(String.self, forKey: .status)
        status = UserVerificationRequestStatus(rawValue: statusString) ?? .requested

        let relationships = try dataValues.nestedContainer(keyedBy: RelationshipKeys.self, forKey: .relationships)
        let requesterRelationship = try relationships.nestedContainer(keyedBy: RelationshipElementKeys.self, forKey: .requester)
        let requesterData = try requesterRelationship.nestedContainer(keyedBy: RelationshipDataKeys.self, forKey: .data)
        requesterUserId = try requesterData.decode(String.self, forKey: .id)

        let requestedRelationship = try relationships.nestedContainer(keyedBy: RelationshipElementKeys.self, forKey: .requested)
        let requestedData = try requestedRelationship.nestedContainer(keyedBy: RelationshipDataKeys.self, forKey: .data)
        requestedUserId = try requestedData.decode(String.self, forKey: .id)
    }

    public init(requesterUserId: String, requestedUserId: String, status: UserVerificationRequestStatus) {
        self.requestedUserId = requestedUserId
        self.requesterUserId = requesterUserId
        self.status = status
    }

    enum RootKeys: String, CodingKey {
        case data
    }

    enum DataKeys: String, CodingKey {
        case type
        case relationships
        case attributes
    }

    enum AttributesKeys: String, CodingKey {
        case status
    }

    enum RelationshipKeys: String, CodingKey {
        case requester
        case requested
    }

    enum RelationshipElementKeys: String, CodingKey {
        case data
    }

    enum RelationshipDataKeys: String, CodingKey {
        case type
        case id
    }


    /**
     When encoding, we need a JSON like this

     {
     "data":{
         "type":"verification-requests",
         "relationships": {
             "requester": {
                "data": { "type": "users", "id": "0c1e858d-4b21-448b-bd58-26bf75b216a5" }
             },
             "requested": {
                "data": { "type": "users", "id": "5a9906a4-7ce8-4ee5-b6ae-e77f4fea5d69" }
             }
         }
         }
     }
     */
    func encode(to encoder: Encoder) throws {
        var rootContainer = encoder.container(keyedBy: RootKeys.self)
        var dataValues = rootContainer.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        try dataValues.encode("verification-requests", forKey: .type)

        var relationshipsContainer = dataValues.nestedContainer(keyedBy: RelationshipKeys.self, forKey: .relationships)
        var requesterContainer = relationshipsContainer.nestedContainer(keyedBy: RelationshipElementKeys.self, forKey: .requester)
        var requestedContainer = relationshipsContainer.nestedContainer(keyedBy: RelationshipElementKeys.self, forKey: .requested)
        var requesterDataContainer = requesterContainer.nestedContainer(keyedBy: RelationshipDataKeys.self, forKey: .data)
        var requestedDataContainer = requestedContainer.nestedContainer(keyedBy: RelationshipDataKeys.self, forKey: .data)

        try requesterDataContainer.encode("users", forKey: .type)
        try requestedDataContainer.encode("users", forKey: .type)
        try requesterDataContainer.encode(requesterUserId, forKey: .id)
        try requestedDataContainer.encode(requestedUserId, forKey: .id)
    }
}
