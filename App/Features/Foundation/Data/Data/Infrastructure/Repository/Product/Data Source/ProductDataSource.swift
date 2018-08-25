import Domain
import RxSwift

protocol ProductDataSource {
  func getProductExtras() -> Single<[Product.Extra]>
}
