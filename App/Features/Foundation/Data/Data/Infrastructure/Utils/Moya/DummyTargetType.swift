import Moya
@testable import Data

struct DummyTargetType: TargetType {
  var baseURL: URL {
    return URL(string: "http://google.es")!
  }
  
  var path: String {
    return "/cool"
  }
  
  var method: Moya.Method {
    return .get
  }
  
  var task: Task {
    return .requestPlain
  }
}
