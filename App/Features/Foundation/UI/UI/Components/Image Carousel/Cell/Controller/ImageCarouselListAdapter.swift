import IGListKit

final class ImageCarouselListAdapter: NSObject, ListAdapterDataSource {
  
  private var images = [CarouselImage]()
  
  func set(_ images: [CarouselImage]) {
    self.images = images
  }
  
  func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    return images
  }
  
  func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    guard let object = object as? CarouselImage else { fatalError() }
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
