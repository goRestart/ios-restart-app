import Domain
import Moya

struct SignInEndpoint: Endpoint {
  
  private let credentials: BasicCredentials
  
  init(credentials: BasicCredentials) {
    self.credentials = credentials
  }
  
  var path: String {
    return "/auth"
  }
  
  var method: Moya.Method {
    return .post
  }
  
  var task: Task {
    let parameters: [String: Any] = [
      "username": credentials.username,
      "password": credentials.password
    ]
    return Task.requestParameters(
      parameters: parameters,
      encoding: JSONEncoding.default
    )
  }
}
