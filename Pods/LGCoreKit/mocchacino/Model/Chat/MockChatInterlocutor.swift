public struct MockChatInterlocutor: ChatInterlocutor {
    public var objectId: String?
    public var name: String
    public var avatar: File?
    public var isBanned: Bool
    public var isMuted: Bool
    public var hasMutedYou: Bool
    public var status: UserStatus
    public var userType: UserType
    
    public init(objectId: String?,
                name: String,
                avatar: File?,
                isBanned: Bool,
                isMuted: Bool,
                hasMutedYou: Bool,
                status: UserStatus,
                userType: UserType) {
        
        self.objectId = objectId
        self.name = name
        self.avatar = avatar
        self.isBanned = isBanned
        self.isMuted = isMuted
        self.hasMutedYou = hasMutedYou
        self.status = status
        self.userType = userType
    }
    
    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatInterlocutor.CodingKeys.objectId.rawValue] = objectId
        result[LGChatInterlocutor.CodingKeys.name.rawValue] = name
        result[LGChatInterlocutor.CodingKeys.avatar.rawValue] = avatar?.fileURL?.absoluteString
        result[LGChatInterlocutor.CodingKeys.isBanned.rawValue] = isBanned
        result[LGChatInterlocutor.CodingKeys.isMuted.rawValue] = isMuted
        result[LGChatInterlocutor.CodingKeys.hasMutedYou.rawValue] = hasMutedYou
        result[LGChatInterlocutor.CodingKeys.status.rawValue] = status.rawValue
        result[LGChatInterlocutor.CodingKeys.type.rawValue] = userType.rawValue
        return result
    }
}
