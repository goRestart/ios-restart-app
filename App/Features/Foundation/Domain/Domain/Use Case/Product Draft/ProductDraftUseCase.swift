import Foundation

public protocol ProductDraftUseCase {
  func save(with title: String, productId: Identifier<Product>)
  func save(description: String)
  func save(price: Double)
  func save(productExtras: [Identifier<Product.Extra>])
  func get() -> ProductDraft
}
