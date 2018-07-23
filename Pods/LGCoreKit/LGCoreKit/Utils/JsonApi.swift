/*
 Build a dict with this structure:
{
    "data": {
        "id": "a748e36e-ddbe-4215-bc02-e9dd491a9aaf",
        "type": "users-reports", // the type of model included in attributes
        "attributes": { // Dictionary with all the attributes
            "reason": "meetup_problem",
            "status": "created",
            "comment": "He did not attend to meetup",
            "score": 4
        }
    }
}
 */
enum JsonApi: String {

    private struct Keys {
        static let data = "data"
        static let id = "id"
        static let type = "type"
        static let attributes = "attributes"
    }

    case listingsReports = "listings-reports"
    case usersReports = "users-reports"

    func makeCreateRequest(attributes: [String: Any]) -> [String: Any] {
        let content: [String: Any] = [Keys.type: rawValue, Keys.attributes: attributes]
        return [Keys.data: content]
    }

    func makeUpdateRequest(id: String, attributes: [String: Any]) -> [String: Any] {
        let content: [String: Any] = [Keys.id: id, Keys.type: rawValue, Keys.attributes: attributes]
        return [Keys.data: content]
    }
}
