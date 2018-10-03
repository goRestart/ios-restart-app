import Domain
import KeychainAccess

private enum Keys {
  static let authToken = "auth_token"
}

struct AuthTokenStorage {
  
  private let keychain: Keychaneable
  
  init(keychain: Keychaneable) {
    self.keychain = keychain
  }
  
  func store(_ authToken: AuthToken) throws {
    try keychain.set(authToken.token, key: Keys.authToken)
  }
  
  func get() -> AuthToken? {
    do {
      guard let token = try keychain.get(Keys.authToken) else { return nil }
      return AuthToken(token: token)
    } catch { return nil }
  }
  
  func clear() {
    try? keychain.remove(Keys.authToken)
  }
}
