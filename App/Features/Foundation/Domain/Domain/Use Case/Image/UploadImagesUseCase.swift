import RxSwift

public protocol UploadImagesUseCase {
  func execute(with images: [Data]) -> Single<[URL]>
}
