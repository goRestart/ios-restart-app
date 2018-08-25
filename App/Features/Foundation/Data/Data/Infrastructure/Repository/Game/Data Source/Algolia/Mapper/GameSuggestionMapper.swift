import Core
import Domain

protocol GameSuggestionMapperProvider {
  func gameSuggestionMapper(with query: String) -> GameSuggestionMapper
}

private enum JSONKey {
  static let id = "id"
  static let value = "value"
}

struct GameSuggestionMapper: Mappable {
  
  private let query: String
  
  init(query: String) {
    self.query = query
  }
  
  func map(_ from: [String: Any]) throws -> GameSearchSuggestion {
    guard let value = from[JSONKey.value] as? String,
      let identifier = from[JSONKey.id] as? String else {
        throw MappableError.invalidInput
    }
    return GameSearchSuggestion(
      id: Identifier<Game>(identifier),
      value: value,
      query: query
    )
  }
}
