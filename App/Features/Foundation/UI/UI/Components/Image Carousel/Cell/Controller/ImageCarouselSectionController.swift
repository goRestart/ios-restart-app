import IGListKit

final class ImageCarouselSectionController: ListSectionController {
  
  private var image: CarouselImage
  
  init(image: CarouselImage) {
    self.image = image
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    return CGSize(
      width: collectionContext!.containerSize.width - Margin.super,
      height: ImageCarouselCell.height
    )
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext!.dequeueReusableCell(of: ImageCarouselCell.self, for: self, at: index) as? ImageCarouselCell else { fatalError() }
    cell.configure(with: image)
    return cell
  }
  
  override func didUpdate(to object: Any) {
    guard let object = object as? CarouselImage else { return }
    self.image = object
  }
}
