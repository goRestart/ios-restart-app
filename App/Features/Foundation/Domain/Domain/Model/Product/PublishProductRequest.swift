import Foundation

public struct PublishProductRequest {
  public let title: String
  public let description: String
  public let price: Product.Price
  public let productExtras: [Identifier<Product.Extra>]
  public let images: [URL]
  
  public init(title: String,
              description: String,
              price: Product.Price,
              productExtras: [Identifier<Product.Extra>],
              images: [URL]) {
    self.title = title
    self.description = description
    self.price = price
    self.productExtras = productExtras
    self.images = images
  }
}
