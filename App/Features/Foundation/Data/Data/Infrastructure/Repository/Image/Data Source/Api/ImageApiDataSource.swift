import Domain
import RxSwift
import Moya
import RxMoya

struct ImageApiDataSource: ImageDataSource {
  
  private let provider: MoyaProvider<ImageService>
  
  init(provider: MoyaProvider<ImageService>) {
    self.provider = provider
  }
  
  func uploadFile(with url: URL) -> Single<Domain.Image> {
    return provider.rx
      .request(.upload(url))
      .map(Image.self)
  }
}
