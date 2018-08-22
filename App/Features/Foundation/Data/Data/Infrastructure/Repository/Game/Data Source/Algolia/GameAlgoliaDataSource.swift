import Domain
import RxSwift
import InstantSearchClient

struct GameAlgoliaDataSource: GameDataSource {
  
  private let gamesIndex: InstantSearchClient.Index
  private let gameSuggestionMapperProvider: GameSuggestionMapperProvider
  
  init(gamesIndex: InstantSearchClient.Index,
       gameSuggestionMapperProvider: GameSuggestionMapperProvider)
  {
    self.gamesIndex = gamesIndex
    self.gameSuggestionMapperProvider = gameSuggestionMapperProvider
  }
  
  func search(with query: String) -> Single<[GameSearchSuggestion]> {
    return gamesIndex.rx
      .search(with: Query(query: query))
      .map(
        gameSuggestionMapperProvider.gameSuggestionMapper(with: query).map
    )
  }
}
