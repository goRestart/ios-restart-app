import Domain
import Data
import Core

struct ProductDraft: ProductDraftUseCase {

  private let productDraftRepository: ProductDraftRepository
  
  init(productDraftRepository: ProductDraftRepository) {
    self.productDraftRepository = productDraftRepository
  }
  
  public func save(productId: Identifier<Product>) {
    productDraftRepository.set(productId: productId)
  }
  
  public func save(description: String) {
    productDraftRepository.set(description: description)
  }
  
  public func save(price: Decimal) {
    productDraftRepository.set(price: price)
  }
  
  public func save(productExtras: [Product.Extra]) {
    productDraftRepository.set(productExtras: productExtras)
  }
  
  public func get() -> Domain.ProductDraft {
    return productDraftRepository.get()
  }
}

// MARK: - Public initializer

extension ProductDraft {
  public init() {
    self.productDraftRepository = resolver.productDraftRepository
  }
}
