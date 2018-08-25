import Foundation

public enum ProductExtraType {
  case sealedProduct
  case collectorsEdition
  case exchangeAccepted
}

extension Product {
  public struct Extra {
    public let identifier: Identifier<Product.Extra>
    public let type: ProductExtraType
    
    public init(identifier: Identifier<Product.Extra>,
                type: ProductExtraType) {
      self.identifier = identifier
      self.type = type
    }
  }
}
