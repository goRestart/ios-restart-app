public struct MockUserRating: UserRating {
    public var objectId: String?
    public var userToId: String
    public var userFrom: UserProduct
    public var type: UserRatingType
    public var value: Int
    public var comment: String?
    public var status: UserRatingStatus
    public var createdAt: Date
    public var updatedAt: Date
}
