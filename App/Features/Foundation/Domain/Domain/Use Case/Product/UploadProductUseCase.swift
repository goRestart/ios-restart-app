import RxSwift

public protocol UploadProductUseCase {
  func execute(with productDraft: ProductDraft) -> Completable
}
