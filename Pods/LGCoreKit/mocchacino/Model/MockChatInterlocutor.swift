public struct MockChatInterlocutor: ChatInterlocutor {
    public var objectId: String?
    public var name: String
    public var avatar: File?
    public var isBanned: Bool
    public var isMuted: Bool
    public var hasMutedYou: Bool
    public var status: UserStatus
    
    public init(objectId: String?,
                name: String,
                avatar: File?,
                isBanned: Bool,
                isMuted: Bool,
                hasMutedYou: Bool,
                status: UserStatus) {
        
        self.objectId = objectId
        self.name = name
        self.avatar = avatar
        self.isBanned = isBanned
        self.isMuted = isMuted
        self.hasMutedYou = hasMutedYou
        self.status = status
    }
    
    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["id"] = objectId
        result["name"] = name
        result["avatar"] = avatar?.fileURL?.absoluteString
        result["is_banned"] = isBanned
        result["is_muted"] = isMuted
        result["has_muted_you"] = hasMutedYou
        result["status"] = status.rawValue
        return result
    }
}
