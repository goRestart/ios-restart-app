public struct MockInactiveInterlocutor: InactiveInterlocutor {
    public var objectId: String?
    public var name: String
    public var avatar: File?
    public var status: UserStatus
    public var lastConnectedAt: Date?
    public var lastUpdatedAt: Date?

    public init(objectId: String?,
                name: String,
                avatar: File?,
                status: UserStatus,
                lastConnectedAt: Date?,
                lastUpdatedAt: Date?) {

        self.objectId = objectId
        self.name = name
        self.avatar = avatar
        self.status = status
        self.lastConnectedAt = lastConnectedAt
        self.lastUpdatedAt = lastUpdatedAt
    }

    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGInactiveInterlocutor.CodingKeys.objectId.rawValue] = objectId
        result[LGInactiveInterlocutor.CodingKeys.name.rawValue] = name
        result[LGInactiveInterlocutor.CodingKeys.avatar.rawValue] = avatar?.fileURL?.absoluteString
        result[LGInactiveInterlocutor.CodingKeys.status.rawValue] = status.rawValue
        result[LGInactiveInterlocutor.CodingKeys.lastConnectedAt.rawValue] = Int64((lastConnectedAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result[LGInactiveInterlocutor.CodingKeys.lastUpdatedAt.rawValue] = Int64((lastUpdatedAt ?? Date()).timeIntervalSince1970 * 1000.0)
        return result
    }
}
