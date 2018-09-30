import Domain

private enum Keys {
  static let code = "code"
  static let emailAlreadyInUse = "email_already_in_use"
  static let usernameAlreadyTaken = "username_already_taken"
}

struct RegisterUserErrorAdapter: ErrorAdapter {
  func make(_ input: Any, _ error: Error) throws -> Error {
    guard let json = input as? [String: Any],
      let code = json[Keys.code] as? String else {
      throw error
    }
    
    switch code {
    case Keys.emailAlreadyInUse:
      return RegisterUserError.emailIsAlreadyRegistered
    case Keys.usernameAlreadyTaken:
      return RegisterUserError.usernameIsAlreadyRegistered
    default:
      return error
    }
  }
}
