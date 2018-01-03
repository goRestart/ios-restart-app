import Domain
import Foundation

private struct JSONKey {
  static let id = "identifier"
}

private struct DomainError {
  static let invalidCredentials = "user.error.invalid_credentials"
}

struct AuthenticateErrorAdapter: ErrorAdapter {
 
  func make(_ input: Input, _ error: Error) throws -> Error {
    guard let json = input as? [String: Any] else {
      return error
    }
    guard let domainError = json[JSONKey.id] as? String,
      domainError == DomainError.invalidCredentials else {
        return error
    }
    return AuthError.invalidCredentials
  }
}
