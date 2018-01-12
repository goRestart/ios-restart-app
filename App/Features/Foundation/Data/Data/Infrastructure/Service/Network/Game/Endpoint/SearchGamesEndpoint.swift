import Domain
import Moya

struct SearchGamesEndpoint: Endpoint {
  
  private let query: String
  
  init(query: String) {
    self.query = query
  }
  
  var path: String {
    return "/search"
  }
  
  var method: Moya.Method {
    return .get
  }
  
  var task: Task {
    let parameters = [
      "query": query.trimmed
    ]
    return Task.requestParameters(
      parameters: parameters,
      encoding: URLEncoding.default
    )
  }
}
