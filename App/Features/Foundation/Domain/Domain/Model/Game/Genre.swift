import Core

public struct Genre: Codable {
  
  public let id: Identifier<Genre>
  public let name: String
  
  public init(id: Identifier<Genre>,
              name: String)
  {
    self.id = id
    self.name = name
  }
}
