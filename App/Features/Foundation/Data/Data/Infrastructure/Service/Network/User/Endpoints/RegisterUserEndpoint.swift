import Domain
import Moya

struct RegisterUserEndpoint: Endpoint {
  
  private let credentials: UserCredentials
  
  init(credentials: UserCredentials) {
    self.credentials = credentials
  }
  
  var path: String {
    return "/"
  }
  
  var method: Moya.Method {
    return .post
  }
  
  var task: Task {
    let parameters = [
      "username": credentials.username.trimmed,
      "password": credentials.password,
      "email": credentials.email
    ]
    return Task.requestParameters(
      parameters: parameters,
      encoding: JSONEncoding.default
    )
  }
}
