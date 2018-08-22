import Domain
import Core
import RxSwift

public struct GameRepository {
  
  private let algoliaDataSource: GameDataSource
  
  init(algoliaDataSource: GameDataSource) {
    self.algoliaDataSource = algoliaDataSource
  }
  
  public func search(with query: String) -> Single<[GameSearchSuggestion]> {
    return algoliaDataSource.search(with: query)
  }
}
