import Domain
import RxSwift

protocol ProductExtrasDataSource {
  func getProductExtras() -> Single<[Product.Extra]>
}

protocol ProductDataSource {
  func publish(with request: PublishProductRequest) -> Completable
}
