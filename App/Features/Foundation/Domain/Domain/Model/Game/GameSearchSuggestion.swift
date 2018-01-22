import Foundation

public struct GameSearchSuggestion: Codable {
  public let id: Identifier<Game>
  public let value: String
  public let query: String
}

extension GameSearchSuggestion: Equatable {
  public static func ==(lhs: GameSearchSuggestion, rhs: GameSearchSuggestion) -> Bool {
    return lhs.id == rhs.id && lhs.query == rhs.query && lhs.value == rhs.value
  }
}
