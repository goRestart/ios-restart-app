import Domain

protocol ProductDraftDataSource {
  func set(images: [UIImage])
  func set(with title: String, productId: Identifier<Product>)
  func set(description: String)
  func set(price: Double)
  func set(productExtras: [Identifier<Product.Extra>])
  func clear()
  func get() -> ProductDraft
}
