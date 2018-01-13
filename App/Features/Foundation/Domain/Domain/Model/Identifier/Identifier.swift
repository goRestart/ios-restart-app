import Foundation

public struct Identifier<Element> {
  
  public let value: String
  
  public init(_ identifier: String) {
    self.value = identifier
  }
  
  public init(_ uuid: UUID) {
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

// MARK: - Equatable

extension Identifier: Equatable {
  public static func ==(lhs: Identifier<Element>, rhs: Identifier<Element>) -> Bool {
    return lhs.value == rhs.value
  }
}
