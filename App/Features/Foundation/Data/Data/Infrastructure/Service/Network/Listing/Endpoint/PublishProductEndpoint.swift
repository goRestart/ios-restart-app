import Domain
import Moya

struct PublishProductEndpoint: Endpoint {

  private let productRequest: ProductRequest

  init(productRequest: ProductRequest) {
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
      "game_id": productRequest.gameId.value,
      "game_console_id": productRequest.gameConsoleId.value,
      "description": productRequest.description,
      "image_ids": productRequest.imageIds.map { $0.value },
      "price": [
        "value": productRequest.price.amount,
        "currency_locale": productRequest.price.locale.currencyCode as Any
      ]
    ]
    return Task.requestParameters(
      parameters: parameters,
      encoding: JSONEncoding.default
    )
  }
}
