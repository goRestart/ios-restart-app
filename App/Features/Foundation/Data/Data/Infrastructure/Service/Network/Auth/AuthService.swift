import Domain
import Moya

enum AuthService: TargetType {
  case authenticate(BasicCredentials)
}

extension AuthService {
  var baseURL: URL {
    return URL(string: "http://auth.restart-api.com")!
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

private func endpoint(for service: AuthService) -> Endpoint {
  switch service {
  case .authenticate(let credentials):
    return AuthenticateEndpoint(credentials: credentials)
  }
}
