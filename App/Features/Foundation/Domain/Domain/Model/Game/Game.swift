import Foundation
import Core

public struct Game: Codable {
  
  public let id: Identifier<Game>
  public let name: String
  public let alternativeNames: [String]?
  public let gameConsoles: [GameConsole]
  public let genres: [Genre]
  public let releasedOn: Date
  
  public init(id: Identifier<Game>,
              name: String,
              alternativeNames: [String]?,
              gameConsoles: [GameConsole],
              genres: [Genre],
              releasedOn: Date)
  {
    self.id = id
    self.name = name
    self.alternativeNames = alternativeNames
    self.gameConsoles = gameConsoles
    self.genres = genres
    self.releasedOn = releasedOn
  }
}
