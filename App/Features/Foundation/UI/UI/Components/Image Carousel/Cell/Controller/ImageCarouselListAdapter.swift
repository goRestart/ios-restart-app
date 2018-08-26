import IGListKit

final class ImageCarouselListAdapter: NSObject, ListAdapterDataSource {
  
  private var images = [Image]()
  
  func set(_ images: [Image]) {
    self.images = images
  }
  
  func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    return images
  }
  
  func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    guard let object = object as? Image else { fatalError() }
    let sectionController = ImageCarouselSectionController(
      image: object
    )
    sectionController.inset = UIEdgeInsets(top: 0, left: Margin.medium, bottom: 0, right: Margin.medium)
    return sectionController
  }
  
  func emptyView(for listAdapter: ListAdapter) -> UIView? {
    return nil
  }
}
