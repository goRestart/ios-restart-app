import RxSwift
import Firebase
 
private enum Products {
  static let path = "products/"
  static let file = "image"
}

public struct ImageUploadService {

  private let storage: Storage
  
  init(storage: Storage) {
    self.storage = storage
  }

  public func upload(_ images: [Data]) -> Single<[URL]> {
    let references = images.map { image -> (StorageReference, Data) in
      let folder = UUID().uuidString

      let reference = storage
        .reference(withPath: Products.path)
        .child(folder)
        .child(Products.file)
      
      return (reference, image)
    }
    
    let uploadImages = references.map { tupple -> Single<URL> in
      let reference = tupple.0
      let image = tupple.1
      
      let metadata = StorageMetadata()
      metadata.contentType = "image/jpeg"
      
      let upload = reference.rx.put(image, with: metadata)
      
      return upload.flatMap { meta in
        let reference = references.filter { $0.0.fullPath == meta.path }.first!.0
        return reference.rx.downloadUrl()
      }
    }
    
    return Single.zip(uploadImages)
  }
}
