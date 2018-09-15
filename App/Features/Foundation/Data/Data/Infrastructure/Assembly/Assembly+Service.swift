import Core

extension Assembly {
  public var imageUploadService: ImageUploadService {
    guard let storage = DataModule.shared.storage else {
      fatalError("Storage not initialized")
    }
    return ImageUploadService(storage: storage)
  }
}
