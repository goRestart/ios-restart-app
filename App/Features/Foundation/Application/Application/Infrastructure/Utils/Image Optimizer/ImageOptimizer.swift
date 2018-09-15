import UIKit
import RxSwift

private enum Compression {
  static let quality = CGFloat(0.6)
}

struct ImageOptimizer {
  func optimize(images: [UIImage]) -> Single<[Data]> {
    return Single.create { event in
      let optimizedImages = images.map { image in
        return image.jpegData(compressionQuality: Compression.quality)
      }.compactMap { $0 }
      
      event(.success(optimizedImages))
      return Disposables.create()
    }
  }
}
