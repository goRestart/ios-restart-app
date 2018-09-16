import Domain
import Moya

enum ProductService: TargetType {
  case publish(PublishProductRequest)
}

extension ProductService {
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

private func endpoint(for service: ProductService) -> Endpoint {
  switch service {
  case .publish(let productRequest):
    return PublishProductEndpoint(productRequest: productRequest)
  }
}
