import Domain

final class ProductDraftInMemoryDataSource: ProductDraftDataSource {
  static let shared = ProductDraftInMemoryDataSource()
  
  private var productId: Identifier<Product>?
  private var description: String?
  private var price: Decimal?
  private var productExtras = [Product.Extra]()
  
  func set(productId: Identifier<Product>) {
    self.productId = productId
  }
  
  func set(description: String) {
    self.description = description
  }
  
  func set(price: Decimal) {
    self.price = price
  }
  
  func set(productExtras: [Product.Extra]) {
    self.productExtras = productExtras
  }
  
  func get() -> ProductDraft {
    return ProductDraft(
      title: productId?.value,
      description: description,
      price: nil,
      productExtras: productExtras,
      productImages: [] // TODO
    )
  }
}
