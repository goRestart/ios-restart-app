
struct AbsoluteUrlRequest<T: BaseURL>: URLRequestAuthenticable {
    let url: URL
    let authLevel: AuthLevel
    let tokenDAO: TokenDAO
    
    init(url: URL, authLevel: AuthLevel, tokenDAO: TokenDAO = InternalCore.tokenDAO) {
        self.url = url
        self.authLevel = authLevel
        self.tokenDAO = tokenDAO
    }
    
    // URLRequestAuthenticable
    var requiredAuthLevel: AuthLevel {
        return authLevel
    }
    
    // URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: url)
        addHeaders(to: &request, for: T.self)
        return request
    }
    
    // ReportableRequest
    var reportingBlacklistedApiError: Array<ApiError> {
        return [.scammer]
    }
    
    private func addHeaders(to request: inout URLRequest, for baseUrl: T.Type) {
        if let token = tokenDAO.value {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        if let contentType = T.contentTypeHeader {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        request.setValue(T.acceptHeader, forHTTPHeaderField: "Accept")
    }
}
