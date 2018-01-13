import RxSwift

public protocol UploadImageUseCase {
  func execute(with url: URL) -> Single<Image>
}
