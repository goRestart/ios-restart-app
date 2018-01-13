import Domain
import RxSwift

enum NetworkError: Error {
  case noInternet
}

final class SearchGamesStub: SearchGamesUseCase {
  
  var games = [Game]()
  var errorToThrow: NetworkError?
  
  func execute(with query: String) -> Single<[Game]> {
    guard let error = errorToThrow else {
      return .just(games)
    }
    return .error(error)
  }
  
  func givenThereAreGameResults() {
    games = [
      Game(id: Identifier("F3A8F140-AF89-40B6-B797-5130CED8A832"),
           name: "Super Mario Bros",
           alternativeNames: nil,
           gameConsoles: [],
           genres: [],
           releasedOn: Date()),
      Game(id: Identifier("F3A8F140-AF89-40B6-B797-5130CED8A832"),
           name: "Mario",
           alternativeNames: nil,
           gameConsoles: [],
           genres: [],
           releasedOn: Date())]
  }
}
