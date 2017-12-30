import Domain
import Moya
import Alamofire

struct AuthenticateEndpoint: Endpoint {
  
  private let credentials: BasicCredentials
  
  init(credentials: BasicCredentials) {
    self.credentials = credentials
  }
  
  var path: String {
    return "/login"
  }
  
  var method: Moya.Method {
    return .post
  }
  
  var task: Task {
    let parameters = [
      "username": credentials.username.trimmed,
      "password": credentials.password
    ]
    return Task.requestParameters(
      parameters: parameters,
      encoding: JSONEncoding.default
    )
  }
}
