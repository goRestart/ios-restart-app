import Domain

protocol ProductDraftDataSource {
  func set(productId: Identifier<Product>)
  func set(description: String)
  func set(price: Decimal)
  func set(productExtras: [Identifier<Product.Extra>])
  func get() -> ProductDraft
}
