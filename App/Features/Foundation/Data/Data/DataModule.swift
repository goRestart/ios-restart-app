import Firebase

public final class DataModule {
  public static let shared = DataModule()

  var storage: Storage?
  
  public func initialize(with storage: Storage) {
    self.storage = storage
    FirebaseApp.configure()
  }
}
