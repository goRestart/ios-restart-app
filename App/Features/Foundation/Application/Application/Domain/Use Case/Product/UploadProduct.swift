import Domain
import Core
import Data
import RxSwift

public struct UploadProduct: UploadProductUseCase {
  
  private let imageOptimizer: ImageOptimizer
  private let uploadImages: UploadImagesUseCase
  private let productRepository: ProductRepository
  
  init(imageOptimizer: ImageOptimizer,
       uploadImages: UploadImagesUseCase,
       productRepository: ProductRepository)
  {
    self.imageOptimizer = imageOptimizer
    self.uploadImages = uploadImages
    self.productRepository = productRepository
  }
  
  public func execute(with productDraft: ProductDraft) -> Completable {
    return imageOptimizer
      .optimize(images: productDraft.productImages)
      .flatMap(uploadImages.execute)
      .asCompletable()
  }
}

// MARK: - Public initializer

extension UploadProduct {
  public init() {
    self.imageOptimizer = ImageOptimizer()
    self.uploadImages = UploadImages()
    self.productRepository = resolver.productRepository
  }
}
