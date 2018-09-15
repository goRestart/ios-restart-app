import Foundation

public struct Identifier<Element>: Equatable, Hashable {
  
  public let value: String
  
  public init(_ identifier: String) {
    self.value = identifier
  }
  
  public init<T>(_ identifier: Identifier<T>)  {
    self.init(identifier.value)
  }
  
  public init(_ uuid: UUID = UUID()) {
    self.value = uuid.uuidString
  }
}

// MARK: - Encodable

extension Identifier: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }
}

extension Identifier: Decodable {
  public init(from decoder: Decoder) throws {
    value = try decoder.singleValueContainer().decode(String.self)
  }
}
