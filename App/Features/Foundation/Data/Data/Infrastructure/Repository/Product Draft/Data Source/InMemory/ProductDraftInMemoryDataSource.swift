import Domain

final class ProductDraftInMemoryDataSource: ProductDraftDataSource {
  static let shared = ProductDraftInMemoryDataSource()
  
  private var productId: Identifier<Product>?
  private var description: String?
  private var price: Decimal?
  private var productExtras = [Identifier<Product.Extra>]()
  
  func set(productId: Identifier<Product>) {
    self.productId = productId
  }
  
  func set(description: String) {
    self.description = description
  }
  
  func set(price: Decimal) {
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
      title: productId?.value,
      description: description,
      price: price,
      productExtras: productExtras,
      productImages: [] // TODO
    )
  }
}
