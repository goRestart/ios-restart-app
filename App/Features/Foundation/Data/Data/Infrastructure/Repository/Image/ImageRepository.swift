import Domain
import Core
import RxSwift

public struct ImageRepository {
  
  private let apiDataSource: ImageDataSource
  
  init(apiDataSource: ImageDataSource) {
    self.apiDataSource = apiDataSource
  }
  
  public func uploadFile(with url: URL) -> Single<Image> {
    return apiDataSource.uploadFile(with: url)
  }
}
