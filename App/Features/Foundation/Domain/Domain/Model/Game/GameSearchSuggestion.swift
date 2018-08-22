import Foundation

public struct GameSearchSuggestion: Equatable {
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
