public struct ImageMultiplierParams {
    public let imageId: String
    public let times: Int
    
    var apiParams: [String : Any] {
        return [CodingKeys.imageId.rawValue : imageId,
                CodingKeys.times.rawValue : times]
    }
    
    public init(imageId: String, times: Int) {
        self.imageId = imageId
        self.times = times
    }
}

private enum CodingKeys: String {
    case imageId, times
}
