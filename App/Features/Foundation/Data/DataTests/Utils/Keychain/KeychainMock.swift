@testable import Data

final class KeychainMock: Keychaneable {
  var getWasCalled = false
  var setWasCalled = false
  var removeWasCalled = false
  
  var getString: String? = nil
  var setValue: String? = nil
  
  func get(_ key: String) throws -> String? {
    getWasCalled = true
    return setValue
  }
  
  func set(_ value: String, key: String) throws {
    setWasCalled = true
    setValue = value
  }
  
  func remove(_ key: String) throws {
    removeWasCalled = true
  }
}
