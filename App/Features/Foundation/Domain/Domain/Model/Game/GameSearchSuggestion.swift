import Foundation

public struct GameSearchSuggestion: Codable {
  public let id: Identifier<Game>
  public let value: String
  public let query: String

  public init(id: Identifier<Game>,
              value: String,
              query: String)
  {
    self.id = id
    self.value = value
    self.query = query
  }
}

extension GameSearchSuggestion: Equatable {
  public static func ==(lhs: GameSearchSuggestion, rhs: GameSearchSuggestion) -> Bool {
    return lhs.id == rhs.id && lhs.query == rhs.query && lhs.value == rhs.value
  }
}
