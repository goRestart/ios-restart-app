import Domain
import Core
import RxSwift

public struct GameRepository {
  
  private let apiDataSource: GameDataSource
  
  init(apiDataSource: GameDataSource) {
    self.apiDataSource = apiDataSource
  }
  
  public func search(with query: String) -> Single<[GameSearchSuggestion]> {
    return apiDataSource.search(with: query)
  }
  
  public func getGameConsoles() -> Single<[GameConsole]> {
    return apiDataSource.getGameConsoles()
  }
}
