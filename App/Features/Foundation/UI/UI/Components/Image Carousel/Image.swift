import IGListKit

public final class Image: ListDiffable {
  public let url: URL?
  
  init(url: URL?) {
    self.url = url
  }
  
  public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let object = object as? Image else { return false }
    return object.url == url
  }
  
  public func diffIdentifier() -> NSObjectProtocol {
    return String(describing: url?.absoluteString) as NSObjectProtocol
  }
}
