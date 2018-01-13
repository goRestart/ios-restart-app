import Domain
import Moya

enum ImageService: TargetType {
  case upload(URL)
}

extension ImageService {
  var baseURL: URL {
    return URL(string: "http://image.restart-api.com")!
  }
  
  var path: String {
    return "/upload"
  }
  
  var method: Moya.Method {
    return .post
  }
  
  var task: Task {
    switch self {
    case .upload(let url):
      return Task.uploadFile(url)
    }
  }
}
