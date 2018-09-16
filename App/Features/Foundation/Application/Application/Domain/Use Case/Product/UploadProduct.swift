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
      .flatMapCompletable { images in
        let request = self.toRequest(with: productDraft, images: images)
        return self.productRepository.publish(with: request)
    }
  }
  
  private func toRequest(with productDraft: ProductDraft, images: [URL]) -> PublishProductRequest {
    guard let title = productDraft.title,
      let description = productDraft.description,
      let price = productDraft.price else {
        fatalError()
    }

    return PublishProductRequest(
      title: title,
      description: description,
      price: price,
      productExtras: productDraft.productExtras,
      images: images
    )
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
