import Domain
import Core
import Data
import RxSwift

public struct GetProductExtras: GetProductExtrasUseCase {
  
  private let productRepository: ProductRepository
  
  init(productRepository: ProductRepository) {
    self.productRepository = productRepository
  }
  
  public func execute() -> Single<[Product.Extra]> {
    return productRepository.getProductExtras()
  }
}

// MARK: - Public initializer

extension GetProductExtras {
  public init() {
    self.productRepository = resolver.productRepository
  }
}
