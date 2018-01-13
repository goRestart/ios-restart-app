import Domain
import Core
import Data
import RxSwift

public struct UploadImage: UploadImageUseCase {
  
  private let imageRepository: ImageRepository
  
  init(imageRepository: ImageRepository) {
    self.imageRepository = imageRepository
  }
  
  public func execute(with url: URL) -> Single<Image> {
    return imageRepository.uploadFile(with: url)
  }
}

// MARK: - Public initializer

extension UploadImage {
  public init() {
    self.imageRepository = resolver.imageRepository
  }
}
