import Domain
import RxSwift

enum NetworkError: Error {
  case noInternet
}

final class SearchGamesStub: SearchGamesUseCase {
  
  var suggestions = [GameSearchSuggestion]()
  var errorToThrow: NetworkError?
  
  func execute(with query: String) -> Single<[GameSearchSuggestion]> {
    guard let error = errorToThrow else {
      return .just(suggestions)
    }
    return .error(error)
  }
  
  func givenThereAreGameResults() {
    suggestions = [
      GameSearchSuggestion(id: Identifier(""),
                           value: "Super Mario Bros",
                           query: "mario"),
      GameSearchSuggestion(id: Identifier(""),
                           value: "Mario Kart",
                           query: "mario")
    ]
  }
}
