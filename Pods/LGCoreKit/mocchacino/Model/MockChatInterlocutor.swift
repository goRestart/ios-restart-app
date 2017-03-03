public struct MockChatInterlocutor: ChatInterlocutor {
    public var objectId: String?
    public var name: String
    public var avatar: File?
    public var isBanned: Bool
    public var isMuted: Bool
    public var hasMutedYou: Bool
    public var status: UserStatus
}
