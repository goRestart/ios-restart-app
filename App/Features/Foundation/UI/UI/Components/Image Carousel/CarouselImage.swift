import IGListKit
import UIKit

public final class CarouselImage: ListDiffable {
  public let url: URL?
  public let image: UIImage?
  
  public init(url: URL? = nil, image: UIImage? = nil) {
    self.url = url
    self.image = image
  }
  
  public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let object = object as? CarouselImage else { return false }
    return object.url == url &&
      object.image == image
  }
  
  public func diffIdentifier() -> NSObjectProtocol {
    return "\(String(describing: url?.absoluteString.hashValue))\(String(describing: image?.hash))" as NSObjectProtocol
  }
}
