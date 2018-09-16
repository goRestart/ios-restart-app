import LGComponents
import RxSwift
import RxCocoa

final class AffiliationStoreViewController: BaseViewController {
    private let storeView = AffiliationStoreView()
    private let viewModel: AffiliationStoreViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: AffiliationStoreViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() {
        super.loadView()
        view.addSubviewForAutoLayout(storeView)
        constraintViewToSafeRootView(storeView)
    }

    override func viewDidLoad() {
        title = "Store"
        view.backgroundColor = storeView.backgroundColor
        storeView.collectionView.dataSource = self
        automaticallyAdjustsScrollViewInsets = false
        
        setupRx()
    }

    private func setupRx() {
        let bindings = [
            viewModel.rx.state.drive(rx.state)
        ]
        bindings.forEach { $0.disposed(by: disposeBag) }
    }

    fileprivate func update(with state: ViewState) {
        switch state {
        case .loading:
            break
        case .data:
            storeView.collectionView.reloadData()
        case .error(_):
            break
        case .empty(_):
            break
        }
    }
}

extension Reactive where Base: AffiliationStoreViewController {
    var state: Binder<ViewState> {
        return Binder(self.base) { controller, state in
            controller.update(with: state)
        }
    }
}

extension AffiliationStoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.purchases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeue(type: AffiliationStoreCell.self, for: indexPath),
            let data = viewModel.purchases[safeAt: indexPath.row] else { return UICollectionViewCell() }
        cell.populate(with: data)
        return cell
    }
}
