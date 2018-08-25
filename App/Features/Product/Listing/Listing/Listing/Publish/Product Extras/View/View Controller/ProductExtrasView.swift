import UI
import RxSwift
import RxCocoa
import IGListKit

final class ProductExtrasView: View {

  private let collectionView: UICollectionView = {
    let collectionViewLayout = ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.backgroundColor = .clear
    return collectionView
  }()
  
  private let nextButton: FullWidthButton = {
    let button = FullWidthButton()
    let title = Localize("product_extras.next_button.title", Table.productExtras).uppercased()
    button.setTitle(title, for: .normal)
    return button
  }()
  
  override func setupView() {
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
  
}
