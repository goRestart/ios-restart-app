import Domain
import UI
import RxSwift
import RxCocoa
import SnapKit
import IGListKit

enum ProductExtraEvent {
  case selectExtra(Identifier<Product.Extra>)
  case unselectExtra(Identifier<Product.Extra>)
}

final class ProductExtrasView: View {
  fileprivate var state = PublishSubject<ProductExtraEvent>()
  
  fileprivate var listAdapterDataSource: ProductExtrasListAdapter?
  private let updater = ListAdapterUpdater()
  fileprivate var listAdapter: ListAdapter!

  private let collectionView: UICollectionView = {
    let collectionViewLayout = ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.backgroundColor = .clear
    return collectionView
  }()
 
  fileprivate let nextButton: FullWidthButton = {
    let button = FullWidthButton()
    let title = Localize("product_extras.next_button.title", Table.productExtras).uppercased()
    button.setTitle(title, for: .normal)
    return button
  }()

  override func setupView() {
    listAdapterDataSource = ProductExtrasListAdapter(state: state)
    
    listAdapter = ListAdapter(updater: updater, viewController: nil)
    listAdapter.collectionView = collectionView
    listAdapter.dataSource = listAdapterDataSource
    
    addSubview(collectionView)
    addSubview(nextButton)
  }
  
  override func setupConstraints() {
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
    nextButton.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-Margin.medium)
    }
  }
}

// MARK: - View Bindings

extension Reactive where Base: ProductExtrasView {
  var productExtras: Binder<[ProductExtraUIModel]> {
    return Binder(self.base) { view, extras in
      view.listAdapterDataSource?.productExtras = extras
      view.listAdapter.performUpdates(animated: true)
    }
  }
  
  var state: PublishSubject<ProductExtraEvent> {
    return base.state
  }
  
  var nextButtonTapped: Observable<Void> {
    return base.nextButton.rx.buttonWasTapped
  }
}
