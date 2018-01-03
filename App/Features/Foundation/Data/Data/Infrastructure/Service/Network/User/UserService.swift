import Domain
import Moya

enum UserService: TargetType {
  case register(UserCredentials)
}

extension UserService {
  var baseURL: URL {
    return URL(string: "http://user.restart-api.com")!
  }
  
  var path: String {
    return endpoint(for: self).path
  }
  
  var method: Moya.Method {
    return endpoint(for: self).method
  }
  
  var task: Task {
    return endpoint(for: self).task
  }
}

private func endpoint(for service: UserService) -> Endpoint {
  switch service {
  case .register(let credentials):
    return RegisterUserEndpoint(credentials: credentials)
  }
}

