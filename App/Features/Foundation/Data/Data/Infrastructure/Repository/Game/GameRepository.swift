import Domain
import Core
import RxSwift

struct GameRepository {
  
  private let apiDataSource: GameDataSource
  
  init(apiDataSource: GameDataSource) {
    self.apiDataSource = apiDataSource
  }
  
  func search(with query: String) -> Single<[Game]> {
    return apiDataSource.search(with: query)
  }
  
  func getGameConsoles() -> Single<[GameConsole]> {
    return apiDataSource.getGameConsoles()
  }
}
