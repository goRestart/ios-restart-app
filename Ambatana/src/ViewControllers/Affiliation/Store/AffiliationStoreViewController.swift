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

        let button = UIBarButtonItem(image: R.Asset.Affiliation.icnThreeDots.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapMoreActions))
        button.tintColor = .grayLight

        let pointsItem = UIBarButtonItem(customView: pointsView)
        navigationItem.rightBarButtonItems = [button, pointsItem]
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
            showLoading()
        case .data:
            updateWithData()
        case .error(let errorModel), .empty(let errorModel):
            update(with: errorModel)
        }
    }

    private func showLoading() {
        errorView.removeFromSuperview()
        showLoadingMessageAlert()
        pointsView.alpha = 0
    }

    private func updateWithData() {
        dismissLoadingMessageAlert()
        errorView.removeFromSuperview()

        pointsView.alpha = 1
        pointsView.populate(with: viewModel.points)
        storeView.collectionView.reloadData()
    }

    private func update(with error: LGEmptyViewModel) {
        dismissLoadingMessageAlert()

        let action = UIAction(interface: .button(R.Strings.commonErrorListRetryButton,
                                                 .primary(fontSize: .medium)),
                              action: error.action ?? {} )
        errorView.populate(message: error.title ?? R.Strings.affiliationStoreUnknownErrorMessage,
                           image: error.icon ?? R.Asset.Affiliation.Error.errorOops.image,
                           action: action)
        view.addSubviewForAutoLayout(errorView)
        constraintViewToSafeRootView(errorView)

        pointsView.alpha = 0
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
