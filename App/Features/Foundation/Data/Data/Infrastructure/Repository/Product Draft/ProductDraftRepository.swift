import Domain

public struct ProductDraftRepository {
  
  private let inMemoryDataSource: ProductDraftDataSource
  
  init(inMemoryDataSource: ProductDraftDataSource) {
    self.inMemoryDataSource = inMemoryDataSource
  }
  
  public func set(with title: String, productId: Identifier<Product>) {
    inMemoryDataSource.set(with: title, productId: productId)
  }
  
  public func set(description: String) {
    inMemoryDataSource.set(description: description)
  }
  
  public func set(price: Double) {
    inMemoryDataSource.set(price: price)
  }
  
  public func set(productExtras: [Identifier<Product.Extra>]) {
    inMemoryDataSource.set(productExtras: productExtras)
  }
  
  public func get() -> ProductDraft {
    return inMemoryDataSource.get()
  }
}
