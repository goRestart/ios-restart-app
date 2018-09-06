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
  fileprivate var state = PublishRelay<ProductExtraEvent>()
  
  fileprivate var listAdapterDataSource: ProductExtrasListAdapter?
  fileprivate lazy var listAdapter: ListAdapter = {
    return ListAdapter(updater: ListAdapterUpdater(), viewController: nil, workingRangeSize: 2)
  }()
  
  private let titleView: TitleView = {
    let titleView = TitleView()
    titleView.title = Localize("product_extras.title", table: Table.productExtras)
    return titleView
  }()
  
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

    listAdapter.collectionView = collectionView
    listAdapter.dataSource = listAdapterDataSource
    
    addSubview(titleView)
    addSubview(collectionView)
    addSubview(nextButton)
  }
  
  override func setupConstraints() {
    titleView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
    }
    collectionView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(titleView.snp.bottom).offset(Margin.medium)
      make.bottom.equalTo(nextButton.snp.top).offset(-Margin.small)
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
    return Binder(self.base) { view, productExtras in
      view.listAdapterDataSource?.set(productExtras)
      view.listAdapter.performUpdates(animated: true)
    }
  }
  
  var state: PublishRelay<ProductExtraEvent> {
    return base.state
  }
  
  var nextButtonTapped: Observable<Void> {
    return base.nextButton.rx.buttonWasTapped
  }
}
