import Domain

struct SignInUserFirebaseErrorAdapter {
  func make(_ error: Error) throws -> Error {
    throw AuthError.invalidCredentials
  }
}
