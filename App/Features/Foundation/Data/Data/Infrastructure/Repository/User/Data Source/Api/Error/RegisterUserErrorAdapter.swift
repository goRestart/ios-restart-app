import Domain
import Foundation

private struct JSONKey {
  static let id = "identifier"
}

private struct DomainError {
  static let invalidUsername = "user.error.invalid_username"
  static let invalidEmail = "user.error.invalid_email"
  static let invalidPassword = "user.error.invalid_password"
  static let usernameAlreadyRegistered = "user.error.username.alredy_registered"
  static let emailAlreadyRegistered = "user.error.email.already_registered"
}

struct RegisterUserErrorAdapter: ErrorAdapter {
  
  func make(_ input: Input, _ error: Error) throws -> Error {
    guard let json = input as? [String: Any] else {
      return error
    }
    guard let domainError = json[JSONKey.id] as? String else {
      return error
    }
    
    switch domainError {
    case DomainError.invalidUsername:
      return RegisterUserError.invalidUsername
    case DomainError.invalidPassword:
      return RegisterUserError.invalidPassword
    case DomainError.invalidEmail:
      return RegisterUserError.invalidEmail
    case DomainError.usernameAlreadyRegistered:
      return RegisterUserError.usernameIsAlreadyRegistered
    case DomainError.emailAlreadyRegistered:
      return RegisterUserError.emailIsAlreadyRegistered
    default:
      return error
    }
  }
}
