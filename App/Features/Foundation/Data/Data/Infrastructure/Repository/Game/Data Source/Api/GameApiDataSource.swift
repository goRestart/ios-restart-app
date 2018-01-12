import Domain
import RxSwift
import Moya
import RxMoya

struct GameApiDataSource: GameDataSource {
  
  private let provider: MoyaProvider<GameService>
  
  init(provider: MoyaProvider<GameService>) {
    self.provider = provider
  }
  
  func search(with query: String) -> Single<[Game]> {
    return provider.rx
      .request(.search(query))
      .map([Game].self)
  }
  
  func getGameConsoles() -> Single<[GameConsole]> {
    return provider.rx
      .request(.gameConsoles)
      .map([GameConsole].self)
  }
}
