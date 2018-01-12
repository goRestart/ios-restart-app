import Domain
import RxSwift

protocol GameDataSource {
  func search(with query: String) -> Single<[Game]>
  func getGameConsoles() -> Single<[GameConsole]>
}
