import LGComponents
import RxSwift
import RxCocoa

final class AffiliationVouchersViewController: BaseViewController {
    private let viewModel: AffiliationVouchersViewModel
    private let vouchersView = AffiliationVouchersView()
    private let errorView = AffiliationStoreErrorView()

    private lazy var datasource: AffiliationVouchersDataSource = {
        let datasource = AffiliationVouchersDataSource()
        datasource.vouchers = viewModel.vouchers
        return datasource
    }()

    private let disposeBag = DisposeBag()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }
    
    init(viewModel: AffiliationVouchersViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    override func loadView() {
        super.loadView()
        view.addSubviewForAutoLayout(vouchersView)
        constraintViewToSafeRootView(vouchersView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        vouchersView.setDataSource(datasource)
        automaticallyAdjustsScrollViewInsets = false
        setupRx()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        setNavBarTitle(R.Strings.affiliationStoreHistory)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
    }

    private func setupRx() {
        let bindings = [
            viewModel.rx.state.throttle(RxTimeInterval(1)).drive(rx.state)
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
    }

    private func updateWithData() {
        dismissLoadingMessageAlert()
        errorView.removeFromSuperview()
        datasource.vouchers = viewModel.vouchers
        vouchersView.reloadData()
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
}

extension Reactive where Base: AffiliationVouchersViewController {
    var state: Binder<ViewState> {
        return Binder(self.base) { controller, state in
            controller.update(with: state)
        }
    }
}
