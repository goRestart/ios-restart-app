import Foundation

public struct ProductPreview {
  public let title: String
  public let description: String
  public let price: Product.Price
  public let productExtras: [Product.Extra]
  public let productImages: [URL]
  
  public init(title: String,
              description: String,
              price: Product.Price,
              productExtras: [Product.Extra],
              productImages: [URL])
  {
    self.title = title
    self.description = description
    self.price = price
    self.productExtras = productExtras
    self.productImages = productImages
  }
}
