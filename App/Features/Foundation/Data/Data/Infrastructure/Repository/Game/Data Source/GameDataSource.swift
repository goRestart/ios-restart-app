import Domain
import RxSwift

protocol GameDataSource {
  func search(with query: String) -> Single<[GameSearchSuggestion]>
  func getGameConsoles() -> Single<[GameConsole]>
}
