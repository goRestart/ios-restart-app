import UI
import IGListKit
import RxSwift

final class ProductExtraSectionController: ListSectionController {

  private var productExtra: ProductExtraUIModel
  
  init(productExtra: ProductExtraUIModel) {
    self.productExtra = productExtra
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    return CGSize(
      width: collectionContext!.containerSize.width - Margin.super,
      height: ProductExtraCell.height
    )
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext!.dequeueReusableCell(of: ProductExtraCell.self, for: self, at: index) as? ProductExtraCell else { fatalError() }
    cell.configure(with: productExtra)
    return cell
  }
  
  override func didUpdate(to object: Any) {
    guard let object = object as? ProductExtraUIModel else { return }
    self.productExtra = object
  }
}
