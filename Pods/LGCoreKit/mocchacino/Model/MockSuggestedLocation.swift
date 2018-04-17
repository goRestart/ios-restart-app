public struct MockSuggestedLocation: SuggestedLocation {
    public var locationId: String
    public var locationName: String
    public var locationAddress: String?
    public var locationCoords: LGLocationCoordinates2D
}
