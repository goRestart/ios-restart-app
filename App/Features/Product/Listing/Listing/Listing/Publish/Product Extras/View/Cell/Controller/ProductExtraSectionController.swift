import UI
import IGListKit
import RxSwift
import RxCocoa

final class ProductExtraSectionController: ListSectionController {

  private var productExtra: ProductExtraUIModel
  private let state: PublishRelay<ProductExtraEvent>
  private let bag = DisposeBag()
  
  init(productExtra: ProductExtraUIModel,
       state: PublishRelay<ProductExtraEvent>)
  {
    self.productExtra = productExtra
    self.state = state
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
    
    cell.rx.isChecked.subscribe(onNext: { [state, productExtra] isChecked in
      if isChecked {
        state.accept(.selectExtra(productExtra.identifier))
        return
      }
      state.accept(.unselectExtra(productExtra.identifier))
    }).disposed(by: bag)
  
    return cell
  }
  
  override func didUpdate(to object: Any) {
    guard let object = object as? ProductExtraUIModel else { return }
    self.productExtra = object
  }
}
