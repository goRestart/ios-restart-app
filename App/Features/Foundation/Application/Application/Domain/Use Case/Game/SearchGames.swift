import Domain
import Core
import Data
import RxSwift

public struct SearchGames: SearchGamesUseCase {
  
  private let gameRepository: GameRepository
  
  init(gameRepository: GameRepository) {
    self.gameRepository = gameRepository
  }
  
  public func execute(with query: String) -> Single<[GameSearchSuggestion]> {
    guard query.trimmed.isEmpty else {
      return gameRepository.search(with: query)
    }
    return .just([])
  }
}

// MARK: - Public initializer

extension SearchGames {
  public init() {
    self.gameRepository = resolver.gameRepository
  }
}
