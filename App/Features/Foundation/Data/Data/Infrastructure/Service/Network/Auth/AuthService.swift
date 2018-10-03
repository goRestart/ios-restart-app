import Domain
import Moya

enum AuthService: TargetType {
  case signIn(BasicCredentials)
}

extension AuthService {
  var baseURL: URL {
    return URL(string: "https://us-central1-restart-backend.cloudfunctions.net/http-api")!
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
  case .signIn(let credentials):
    return SignInEndpoint(credentials: credentials)
  }
}
