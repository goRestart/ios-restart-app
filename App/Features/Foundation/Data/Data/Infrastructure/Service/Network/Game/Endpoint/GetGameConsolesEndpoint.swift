import Domain
import Moya

struct GetGameConsolesEndpoint: Endpoint {
  
  var path: String {
    return "/game-console"
  }
  
  var method: Moya.Method {
    return .get
  }
  
  var task: Task {
    return Task.requestPlain
  }
}
