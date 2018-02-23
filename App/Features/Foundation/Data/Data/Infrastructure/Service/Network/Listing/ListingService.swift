import Domain
import Moya

enum ListingService: TargetType {
  case publish(ProductRequest)
}

extension ListingService {
  var baseURL: URL {
    return URL(string: "http://listing.restart-api.com")!
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

private func endpoint(for service: ListingService) -> Endpoint {
  switch service {
  case .publish(let productRequest):
    return PublishProductEndpoint(productRequest: productRequest)
  }
}
