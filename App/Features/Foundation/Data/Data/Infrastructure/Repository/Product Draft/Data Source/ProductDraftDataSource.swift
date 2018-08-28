import Domain

protocol ProductDraftDataSource {
  func set(productId: Identifier<Product>)
  func set(description: String)
  func set(price: Decimal)
  func set(productExtras: [Product.Extra])
  
  func get() -> ProductDraft
}
