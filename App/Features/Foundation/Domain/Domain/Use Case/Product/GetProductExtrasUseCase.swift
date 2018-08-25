import RxSwift

public protocol GetProductExtrasUseCase {
  func execute() -> Single<[Product.Extra]>
}
