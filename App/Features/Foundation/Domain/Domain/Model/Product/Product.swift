import Foundation

public struct Product {
  public let identifier: Identifier<Product>
  
  public init(identifier: Identifier<Product>) {
    self.identifier = identifier
  }
}
