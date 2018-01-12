import Foundation

public struct GameConsole: Codable {
  
  public let id: Identifier<GameConsole>
  public let name: String
  public let alternativeName: String?
  public let manufacturer: Manufacturer?
  
  public init(id: Identifier<GameConsole>,
              name: String,
              alternativeName: String?,
              manufacturer: Manufacturer?)
  {
    self.id = id
    self.name = name
    self.alternativeName = alternativeName
    self.manufacturer = manufacturer
  }
}
