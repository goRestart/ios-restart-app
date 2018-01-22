import Domain
import RxSwift
import Moya
import RxMoya

struct GameApiDataSource: GameDataSource {
  
  private let provider: MoyaProvider<GameService>
  
  init(provider: MoyaProvider<GameService>) {
    self.provider = provider
  }
  
  func search(with query: String) -> Single<[GameSearchSuggestion]> {
    return provider.rx
      .request(.search(query))
      .map([GameSearchSuggestion].self)
  }
  
  func getGameConsoles() -> Single<[GameConsole]> {
    return provider.rx
      .request(.gameConsoles)
      .map([GameConsole].self)
  }
}
