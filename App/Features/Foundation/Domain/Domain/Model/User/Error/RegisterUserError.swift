import Foundation

public enum RegisterUserError: Error {
  case invalidUsername
  case invalidPassword
  case invalidEmail
  case usernameIsAlreadyRegistered
  case emailIsAlreadyRegistered
}
