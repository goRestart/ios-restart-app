import LGComponents
import RxSwift
import RxCocoa

final class AffiliationStoreViewController: BaseViewController {
    private let storeView = AffiliationStoreView()
    private let errorView = AffiliationStoreErrorView()

    private let viewModel: AffiliationStoreViewModel
    private let pointsView = AffiliationStorePointsView()

    fileprivate let disposeBag = DisposeBag()

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
        navigationController?.navigationBar.backgroundColor = .clear


        let button = UIBarButtonItem(image: R.Asset.Affiliation.icnThreeDots.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapMoreActions))
        button.tintColor = .grayRegular

        let pointsItem = UIBarButtonItem(customView: pointsView)
        navigationItem.rightBarButtonItems = [button, pointsItem]
    }

    private func setupRx() {
        let bindings = [
            viewModel.rx.state.throttle(RxTimeInterval(1)).drive(rx.state),
            viewModel.rx.redeemTapped.drive(rx.redeemCell),
            viewModel.rx.points.drive(rx.points),
            viewModel.rx.pointsAlpha.drive(rx.pointsAlpha)
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

        pointsView.alpha = state == .data ? 1 : 0
    }

    private func showLoading() {
        errorView.removeFromSuperview()
        showLoadingMessageAlert()
    }

    private func updateWithData() {
        dismissLoadingMessageAlert()
        errorView.removeFromSuperview()

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
    }

    fileprivate func updatePoints(with alpha: CGFloat) {
        pointsView.alpha = alpha
    }

    fileprivate func updatePoints(with points: Int) {
        pointsView.populate(with: points)
    }

    fileprivate func updateRedeem(with state: ViewState) {
        switch state {
        case .loading:
            showLoading()
        case .data:
            dismissLoadingMessageAlert({ [weak self] in
                self?.showRedeemSuccess()
            })
        case .empty(_), .error(_):
            showAlert(R.Strings.affiliationStoreGenericError, message: nil, actions: [])
            delay(2) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
        pointsView.alpha = state == .loading ? 0 : 1
    }

    fileprivate func showRedeemSuccess() {
        let action = UIAction(interface: .button(R.Strings.commonOk, .primary(fontSize: .medium)),
                              action: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        })
        let data = AffiliationModalData(
            icon: R.Asset.Affiliation.icnModalSuccess.image,
            headline: R.Strings.affiliationStoreRedeemGiftSuccessHeadline,
            subheadline: R.Strings.affiliationStoreRedeemGiftSuccessSubheadlineWithEmail,
            primary: action,
            secondary: nil
        )
        let vm = AffiliationModalViewModel(data: data)
        let vc = AffiliationModalViewController(viewModel: vm)

        vm.active = true
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: nil)
    }

    fileprivate func update(with points: Int) {
        pointsView.populate(with: points)
    }
}

extension AffiliationStoreViewController {
    @objc func didTapMoreActions() {
        showActionSheet(R.Strings.commonCancel, actions: viewModel.moreActions, barButtonItem: nil)
    }
}

extension AffiliationStoreViewController {
    func openEditEmail(action: UIAlertAction) {
        viewModel.openEditEmail()
    }

    func closeAlert(action: UIAlertAction) {
        dismiss(animated: true, completion: nil)
    }

    func update(with model: RedeemCellModel) {
        let actions: [UIAlertAction]
        let title = R.Strings.affiliationStoreRedeemGiftSuccessHeadline
        let message: String
        if model.email != nil {
            message = R.Strings.affiliationStoreRedeemGiftSuccessSubheadlineWithEmail
            actions = [
                UIAlertAction(title: R.Strings.commonCancel, style: .default, handler: closeAlert),
                UIAlertAction(title: R.Strings.affiliationStoreRedeemGiftEditEmail,
                              style: .default,
                              handler: openEditEmail),
                UIAlertAction(title: R.Strings.affiliationStoreRedeemGiftSend,
                              style: .default,
                              handler: { [weak self] _ in
                                self?.redeem(for: model.index)
                })
            ]
        } else {
            message = R.Strings.affiliationStoreRedeemGiftSuccessSubheadlineWithoutEmail
            actions = [
                UIAlertAction(title: R.Strings.commonCancel, style: .default, handler: closeAlert),
                UIAlertAction(title: R.Strings.affiliationStoreRedeemGiftAddEmail,
                              style: .default,
                              handler: openEditEmail)
            ]
        }
        showEmailAlert(title: title, message: message, actions: actions)
    }

    private func redeem(for index: Int) {
        viewModel
            .redeem(at: index)
            .drive(onNext: { [weak self] (state) in
                self?.updateRedeem(with: state)
            }).disposed(by: disposeBag)
    }

    private func showEmailAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.add(actions)
        present(alert, animated: true, completion: nil)
    }
}

extension Reactive where Base: AffiliationStoreViewController {
    var state: Binder<ViewState> {
        return Binder(self.base) { controller, state in
            controller.update(with: state)
        }
    }

    var points: Binder<Int> {
        return Binder(self.base) { controller, points in
            controller.updatePoints(with: points)
        }
    }

    var pointsAlpha: Binder<CGFloat> {
        return Binder(self.base) { controller, alpha in
            controller.updatePoints(with: alpha)
        }
    }

    var redeemCell: Binder<RedeemCellModel?> {
        return Binder(self.base) { controller, redeemCell in
            guard let redeemCell = redeemCell else { return }
            controller.update(with: redeemCell)
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
        cell.tag = indexPath.row

        cell.rx.redeemTap
            .bind { [weak self] in self?.viewModel.cellRedeemTapped.accept(cell.tag) }
            .disposed(by: cell.disposeBag)
        return cell
    }
}
