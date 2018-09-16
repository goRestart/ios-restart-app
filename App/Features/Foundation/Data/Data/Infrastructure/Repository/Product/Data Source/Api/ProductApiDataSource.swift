import Domain
import Moya
import RxMoya
import RxSwift

struct ProductApiDataSource: ProductDataSource {
  
  private let provider: MoyaProvider<ProductService>
  
  init(provider: MoyaProvider<ProductService>) {
    self.provider = provider
  }
  
  func publish(with request: PublishProductRequest) -> Completable {
    return provider.rx.request(.publish(request))
      .filterSuccessfulStatusCodes()
      .asCompletable()
  }
}
