import Domain
import Core
import Data
import RxSwift

public struct GetGameConsoles: GetGameConsolesUseCase {
  
  private let gameRepository: GameRepository
  
  init(gameRepository: GameRepository) {
    self.gameRepository = gameRepository
  }
  
  public func execute() -> Single<[GameConsole]> {
    return gameRepository.getGameConsoles()
  }
}

// MARK: - Public initializer

extension GetGameConsoles {
  public init() {
    self.gameRepository = resolver.gameRepository
  }
}
