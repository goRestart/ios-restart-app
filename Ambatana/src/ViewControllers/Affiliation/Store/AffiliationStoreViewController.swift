import LGComponents
import RxSwift
import RxCocoa

final class AffiliationStoreViewController: BaseViewController {
    private let storeView = AffiliationStoreView()
    private let errorView = AffiliationStoreErrorView()

    private let viewModel: AffiliationStoreViewModel
    private let pointsView = AffiliationStorePointsView()

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

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    override func viewDidLoad() {
        view.backgroundColor = storeView.backgroundColor
        storeView.collectionView.dataSource = self
        automaticallyAdjustsScrollViewInsets = false
        
        setupRx()
    }

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        setNavBarTitle(R.Strings.affiliationStoreTitle)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear

        // TODO: Include gray dots
        pointsView.populate(with: AffiliationPoints(points: 15))
        let pointsItem = UIBarButtonItem.init(customView: pointsView)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: R.Asset.IconsButtons.icMoreOptions.image,
                            style: .plain,
                            target: self,
                            action: #selector(didTapMoreActions)),
            pointsItem
        ]
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
            errorView.removeFromSuperview()
        case .data:
            errorView.removeFromSuperview()
            storeView.collectionView.reloadData()
        case .error(let errorModel):
            let action = UIAction(interface: .button(R.Strings.commonErrorListRetryButton,
                                                     .primary(fontSize: .medium)),
                                  action: errorModel.action ?? {} )
            errorView.populate(message: errorModel.title ?? R.Strings.affiliationStoreUnknownErrorMessage,
                               image: R.Asset.IconsButtons.icReportSpammer.image,
                               action: action)
            view.addSubviewForAutoLayout(errorView)
            constraintViewToSafeRootView(errorView)
        case .empty(_):
            break
        }
    }

    fileprivate func update(with points: UInt) {
        pointsView.populate(with: AffiliationPoints(points: points))
    }
}

extension AffiliationStoreViewController {
    @objc func didTapMoreActions() {
        showActionSheet(R.Strings.commonCancel, actions: viewModel.moreActions, barButtonItem: nil)
    }
}

extension Reactive where Base: AffiliationStoreViewController {
    var state: Binder<ViewState> {
        return Binder(self.base) { controller, state in
            controller.update(with: state)
        }
    }

    var points: Binder<UInt> {
        return Binder(self.base) { controller, points in
            controller.update(with: points)
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
