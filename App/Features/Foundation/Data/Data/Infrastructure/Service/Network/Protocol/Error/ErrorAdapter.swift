import Foundation

protocol ErrorAdapter {
  typealias Input = Any
  
  func make(_ input: Input, _ error: Error) throws -> Error
}
