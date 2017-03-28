public struct MockChat: Chat {
    public var objectId: String?
    public var product: Product
    public var userFrom: UserListing
    public var userTo: UserListing
    public var msgUnreadCount: Int
    public var messages: [Message]
    public var updatedAt: Date?
    public var forbidden: Bool
    public var archivedStatus: ChatArchivedStatus
}
