import Domain
import RxSwift

protocol ImageDataSource {
  func uploadFile(with url: URL) -> Single<Image>
}
