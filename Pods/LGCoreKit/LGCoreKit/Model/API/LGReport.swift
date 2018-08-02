import Foundation

struct LGReport: Report {
    let objectId: String?
    let reporterIdentity: String
    let reportedIdentity: String
    let reason: String
    let status: String
    let comment: String?
    let score: Int?
}

extension LGReport: Decodable {
/**
     {
        "data": {
            "id": "523d1c1b-8534-4be4-9203-3d14280b0a44",
            "type": "users-reports",
            "attributes": {
                "id": "523d1c1b-8534-4be4-9203-3d14280b0a44",
                "reporter-identity": "ab479086-fd15-4791-bae5-9718efebaa50",
                "reported-identity": "e47d8d9b-648e-444c-a2ce-5cbbd9a8855a",
                "reason": "meetup_problem",
                "status": "created",
                "comment": "He did not attend to meetup"
                "score": 3
            }
         }
     }
 */
    enum ReportRootKeys: String, CodingKey {
        case data
    }

    enum ReportDataKeys: String, CodingKey {
        case attributes
    }

    enum CodingKeys: String, CodingKey {
        case id, reporterIdentity = "reporter-identity", reportedIdentity = "reported-identity", reason, status, comment, score
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: ReportRootKeys.self)
        let dataValues = try rootContainer.nestedContainer(keyedBy: ReportDataKeys.self, forKey: .data)
        let attributes = try dataValues.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        objectId = try attributes.decodeIfPresent(String.self, forKey: .id)
        reporterIdentity = try attributes.decode(String.self, forKey: .reporterIdentity)
        reportedIdentity = try attributes.decode(String.self, forKey: .reportedIdentity)
        reason = try attributes.decode(String.self, forKey: .reason)
        status = try attributes.decode(String.self, forKey: .status)
        comment = try attributes.decodeIfPresent(String.self, forKey: .comment)
        score = try attributes.decodeIfPresent(Int.self, forKey: .score)
    }
}
