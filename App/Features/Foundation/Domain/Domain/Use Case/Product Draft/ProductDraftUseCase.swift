import Foundation

public protocol ProductDraftUseCase {
  func save(images: [UIImage])
  func save(with title: String, productId: Identifier<Product>)
  func save(description: String)
  func save(price: Double)
  func save(productExtras: [Identifier<Product.Extra>])
  func clear()
  func get() -> ProductDraft
}
