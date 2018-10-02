import Moya

struct AuthTokenPlugin: PluginType {
  
  private let authTokenStorage: AuthTokenStorage
  
  init(authTokenStorage: AuthTokenStorage) {
    self.authTokenStorage = authTokenStorage
  }
  
  func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    var request = request

    if let authToken = authTokenStorage.get() {
      let bearer = "Bearer \(authToken.token)"
      request.addValue(bearer, forHTTPHeaderField: "Authorization")
    }
    return request
  }
}
