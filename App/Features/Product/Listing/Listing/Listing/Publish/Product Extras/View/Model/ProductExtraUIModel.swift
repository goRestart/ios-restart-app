import Domain
import UI
import IGListKit

final class ProductExtraUIModel: ListDiffable {
  
  private let productExtra: Product.Extra
  
  init(productExtra: Product.Extra) {
    self.productExtra = productExtra
  }
  
  var isSelected = false
  var type: String {
    switch productExtra.type {
    case .collectorsEdition:
      return Localize("product_extras.type.collectors_edition", Table.productExtras)
    case .sealedProduct:
      return Localize("product_extras.type.sealed_product", Table.productExtras)
    case .exchangeAccepted:
      return Localize("product_extras.type.exchange_accepted", Table.productExtras)
    case .unknown:
      return ""
    }
  }
  
  // MARK: - ListDiffable
  
  func diffIdentifier() -> NSObjectProtocol {
    return type as NSObjectProtocol
  }
  
  func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let object = object as? ProductExtraUIModel else {
      return false
    }
    return object.productExtra == productExtra &&
      object.isSelected == isSelected &&
      object.type == type
  }
}
