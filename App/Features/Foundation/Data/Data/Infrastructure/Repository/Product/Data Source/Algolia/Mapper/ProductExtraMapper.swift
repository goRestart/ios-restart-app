import Domain
import Core

private enum JSONKey {
  static let id = "objectID"
  static let type = "type"
}

private enum ProductExtraTypeJSONKey {
  static let collectorsEdition = "collections_edition"
  static let sealedProduct = "sealed_product"
  static let exchangeAccepted = "exchange_accepted"
}

struct ProductExtraMapper: Mappable {
  func map(_ from: [String: Any]) throws -> Product.Extra {
    guard let type = from[JSONKey.type] as? String,
      let identifier = from[JSONKey.id] as? String else {
        throw MappableError.invalidInput
    }
    return Product.Extra(
      identifier: Identifier<Product.Extra>(identifier),
      type: map(type: type)
    )
  }
  
  private func map(type: String) -> ProductExtraType {
    switch type {
    case ProductExtraTypeJSONKey.collectorsEdition:
      return .collectorsEdition
    case ProductExtraTypeJSONKey.sealedProduct:
      return .sealedProduct
    case ProductExtraTypeJSONKey.exchangeAccepted:
      return .exchangeAccepted
    default:
      return .unknown
    }
  }
}
