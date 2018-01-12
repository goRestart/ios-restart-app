import Foundation

public struct Manufacturer: Codable {
  
  public let id: Identifier<Manufacturer>
  public let name: String
  
  public init(id: Identifier<Manufacturer>,
              name: String)
  {
    self.id = id
    self.name = name
  }
}
