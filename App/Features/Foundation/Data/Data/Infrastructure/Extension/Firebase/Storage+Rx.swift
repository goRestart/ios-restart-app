import RxSwift
import FirebaseStorage

extension Reactive where Base: StorageReference {
  func put(_ data: Data, with metadata: StorageMetadata? = nil) -> Single<StorageMetadata> {
    return Single.create { event in
      let task = self.base.putData(data, metadata: metadata) { metadata, error in
        if let metadata = metadata {
          event(.success(metadata))
        }
        
        if let error = error {
          event(.error(error))
        }
      }
      return Disposables.create {
        task.cancel()
      }
    }
  }
  
  func downloadUrl() -> Single<URL> {
    return Single.create { event in
      self.base.downloadURL(completion: { url, error in
        if let url = url {
          event(.success(url))
        }
        
        if let error = error {
          event(.error(error))
        }
      })
      return Disposables.create()
    }
  }
}
