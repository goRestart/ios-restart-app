import Domain
import Moya

enum GameService: TargetType {
  case gameConsoles
  case search(String)
}

extension GameService {
  var baseURL: URL {
    return URL(string: "http://game.restart-api.com")!
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

private func endpoint(for service: GameService) -> Endpoint {
  switch service {
  case .gameConsoles:
    return GetGameConsolesEndpoint()
  case .search(let query):
    return SearchGamesEndpoint(query: query)
  }
}
