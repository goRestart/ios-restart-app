public struct MockUser: User {
    public var objectId: String?
    public var name: String?
    public var avatar: File?
    public var postalAddress: PostalAddress
    public var accounts: [Account]
    public var ratingAverage: Float?
    public var ratingCount: Int
    public var status: UserStatus
    public var isDummy: Bool
}
