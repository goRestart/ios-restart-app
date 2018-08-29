import Foundation

public protocol ProductDraftUseCase {
  func save(productId: Identifier<Product>)
  func save(description: String)
  func save(price: Decimal)
  func save(productExtras: [Identifier<Product.Extra>])
  func get() -> ProductDraft
}
