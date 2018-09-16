import Domain
import Moya

struct PublishProductEndpoint: Endpoint {
  
  private let productRequest: PublishProductRequest
  
  init(productRequest: PublishProductRequest) {
    self.productRequest = productRequest
  }
  
  var path: String {
    return "/product"
  }
  
  var method: Moya.Method {
    return .post
  }
  
  var task: Task {
    let parameters: [String: Any] = [
      "title": productRequest.title,
      "description": productRequest.description,
      "price": [
        "amount": productRequest.price.amount,
        "currency": productRequest.price.locale.currencyCode as Any
      ],
      "product_extras": productRequest.productExtras.map { $0.value },
      "images": productRequest.images.map { $0.absoluteString }
    ]
    return Task.requestParameters(
      parameters: parameters,
      encoding: JSONEncoding.default
    )
  }
}
