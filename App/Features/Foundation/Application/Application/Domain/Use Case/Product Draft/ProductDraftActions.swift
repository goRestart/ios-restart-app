import Domain
import Data
import Core

public struct ProductDraftActions: ProductDraftUseCase {
  
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
  
  public func save(productExtras: [Identifier<Product.Extra>]) {
    productDraftRepository.set(productExtras: productExtras)
  }
  
  public func get() -> ProductDraft {
    return productDraftRepository.get()
  }
}

// MARK: - Public initializer

extension ProductDraftActions {
  public init() {
    self.productDraftRepository = resolver.productDraftRepository
  }
}
