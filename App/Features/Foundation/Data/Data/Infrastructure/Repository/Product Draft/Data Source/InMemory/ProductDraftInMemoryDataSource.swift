import Domain

final class ProductDraftInMemoryDataSource: ProductDraftDataSource {
  static let shared = ProductDraftInMemoryDataSource()
  
  private var images = [UIImage]()
  private var productTitle: String?
  private var productId: Identifier<Product>?
  private var description: String?
  private var price: Double?
  private var productExtras = [Identifier<Product.Extra>]()
  
  func set(images: [UIImage]) {
    self.images = images
  }
  
  func set(with title: String, productId: Identifier<Product>) {
    self.productTitle = title
    self.productId = productId
  }
  
  func set(description: String) {
    self.description = description
  }
  
  func set(price: Double) {
    self.price = price
  }
  
  func set(productExtras: [Identifier<Product.Extra>]) {
    self.productExtras = productExtras
  }
  
  func get() -> ProductDraft {
    var price: Product.Price?
    if let amount = self.price {
      price = Product.Price(amount: amount, locale: .current)
    }
    
    return ProductDraft(
      title: productTitle,
      description: description,
      price: price,
      productExtras: productExtras,
      productImages: images
    )
  }
}
