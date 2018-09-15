import Domain
import Core
import Data
import RxSwift

public struct UploadImages: UploadImagesUseCase {
  
  private let imageUploadService: ImageUploadService
  
  init(imageUploadService: ImageUploadService) {
    self.imageUploadService = imageUploadService
  }
  
  public func execute(with images: [Data]) -> Single<[URL]> {
    return imageUploadService.upload(images)
  }
}

// MARK: - Public initializer

extension UploadImages {
  public init() {
    self.imageUploadService = resolver.imageUploadService
  }
}
