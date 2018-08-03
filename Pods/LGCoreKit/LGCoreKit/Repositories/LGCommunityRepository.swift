import Foundation

public class LGCommunityRepository: CommunityRepository {

    private let tokenDAO: TokenDAO
    private let rootPath = "/redirect"

    init(tokenDAO: TokenDAO) {
        self.tokenDAO = tokenDAO
    }

    public func buildCommunityURLRequest() -> URLRequest? {
        guard var url = URL(string: EnvironmentProxy.sharedInstance.communityBaseURL) else { return nil }
        url.appendPathComponent(rootPath)
        var request = URLRequest(url: url)

        if let token = tokenDAO.token.value {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }

}
