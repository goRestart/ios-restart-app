import Foundation

public struct Identifier<Element>: Codable {
  
  public let value: String
  
  public init(_ identifier: String) {
    self.value = identifier
  }
  
  public init(_ uuid: UUID) {
    self.value = uuid.uuidString
  }
}
