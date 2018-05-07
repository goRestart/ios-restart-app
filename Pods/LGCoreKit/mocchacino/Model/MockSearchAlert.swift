public struct MockSearchAlert: SearchAlert {
    public var objectId: String?
    public var query: String
    public var enabled: Bool
    public var createdAt: TimeInterval
    
    public init(objectId: String?, query: String, enabled: Bool, createdAt: TimeInterval) {
        self.objectId = objectId
        self.query = query
        self.enabled = enabled
        self.createdAt = createdAt
    }
}
