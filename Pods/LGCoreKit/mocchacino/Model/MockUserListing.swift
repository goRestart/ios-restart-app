public struct MockUserListing: UserListing {
    public var objectId: String?
    public var name: String?
    public var avatar: File?
    public var postalAddress: PostalAddress
    public var status: UserStatus
    public var banned: Bool?
    public var isDummy: Bool
    public var type: UserType
}
