import Domain

struct SignInUserErrorAdapter {
  func make(_ error: Error) throws -> Error {
    throw AuthError.invalidCredentials
  }
}
