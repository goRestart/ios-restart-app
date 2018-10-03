import Domain

protocol AuthTokenStorage {
  func store(_ authToken: AuthToken) throws
  func get() -> AuthToken?
  func clear()
}
