import Domain

protocol ProductDraftDataSource {
  func set(with title: String, productId: Identifier<Product>)
  func set(description: String)
  func set(price: Double)
  func set(productExtras: [Identifier<Product.Extra>])
  func get() -> ProductDraft
}
