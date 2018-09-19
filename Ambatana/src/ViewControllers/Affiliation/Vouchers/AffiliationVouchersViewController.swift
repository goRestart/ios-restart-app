import LGComponents
import RxSwift
import RxCocoa

final class AffiliationVouchersViewController: BaseViewController {
    private let viewModel: AffiliationVouchersViewModel
    private let vouchersView = AffiliationVouchersView()
    private let errorView = AffiliationStoreErrorView()

    private lazy var datasource: AffiliationVouchersDataSource = {
        let datasource = AffiliationVouchersDataSource()
        datasource.vouchers = viewModel.vouchersCellData
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

        datasource.resendRelay
            .asObservable()
            .bind { [weak self] (index) in
            self?.resend(index)
        }.disposed(by: disposeBag)
    }

    private func resend(_ index: Int) {
        viewModel
            .resend(at: index)
            .drive(onNext: { [weak self] (state) in
                self?.updateResend(with: state)
        }).disposed(by: disposeBag)
    }

    private func updateResend(with state: ViewState) {
        switch state {
        case .loading:
            showLoading()
        case .data:
            dismissLoadingMessageAlert({ [weak self] in
                self?.showResendSucces()
            })
        case .error(_), .empty(_):
            dismissLoadingMessageAlert({ [weak self] in
                self?.showResendError()
            })
        }
    }

    private func showResendError() {
        showAlert(R.Strings.affiliationStoreGenericError, message: nil, actions: [])
        delay(2) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    private func showResendSucces() {
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
        datasource.vouchers = viewModel.vouchersCellData
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
