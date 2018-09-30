import Domain
import Moya

struct RegisterUserEndpoint: Endpoint {
  
  private let credentials: UserCredentials
  
  init(credentials: UserCredentials) {
    self.credentials = credentials
  }
  
  var path: String {
    return "/user"
  }
  
  var method: Moya.Method {
    return .post
  }
  
  var task: Task {
    let parameters: [String: Any] = [
      "username": credentials.username,
      "password": credentials.password,
      "email": credentials.email
    ]
    return Task.requestParameters(
      parameters: parameters,
      encoding: JSONEncoding.default
    )
  }
}
