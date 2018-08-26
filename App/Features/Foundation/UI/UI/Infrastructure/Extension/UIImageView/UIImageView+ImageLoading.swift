import UIKit
import Kingfisher

extension UIImageView {
  func set(url: URL, placeholder: UIImage? = nil) {
    kf.setImage(with: url, placeholder: placeholder, options: [
      .backgroundDecode,
      .transition(.fade(0.1)),
    ])
  }
  
  func cancel() {
    kf.cancelDownloadTask()
  }
}
