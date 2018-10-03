import KeychainAccess

struct Keychain: Keychaneable {
  
  private let keychain: KeychainAccess.Keychain
  
  init(keychain: KeychainAccess.Keychain) {
    self.keychain = keychain
  }
  
  func set(_ value: String, key: String) throws {
    try keychain.set(value, key: key)
  }
  
  func get(_ key: String) throws -> String? {
    return try keychain.get(key)
  }
  
  func remove(_ key: String) throws {
    try keychain.remove(key)
  }
}
