import Result

public typealias FeedResult = Result<Feed, RepositoryError>
public typealias FeedCompletion = (FeedResult) -> Void

public protocol FeedRepository {
    
    func index(parameters: FeedIndexParameters, completion: @escaping FeedCompletion)
    
    func index(page: URL, completion: @escaping FeedCompletion)
}

public struct FeedIndexParameters {
    let countryCode: String
    let location: LGLocationCoordinates2D
    let locale: String
    let page: Int
    let pageSize: Int
    let variant: String
    
    public init(countryCode: String, location: LGLocationCoordinates2D, locale: String, page: Int,
                pageSize: Int, variant: String) {
        self.countryCode = countryCode
        self.location = location
        self.locale = locale
        self.page = page
        self.pageSize = pageSize
        self.variant = variant
    }
}
