public struct MockChat: Chat {
    public var objectId: String?
    public var product: Product
    public var userFrom: UserProduct
    public var userTo: UserProduct
    public var msgUnreadCount: Int
    public var messages: [Message]
    public var updatedAt: Date?
    public var forbidden: Bool
    public var archivedStatus: ChatArchivedStatus
}
