import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsPayoutViewController: BaseViewController {
    private let viewModel: P2PPaymentsPayoutViewModel
    private let disposeBag = DisposeBag()
    private let personalInfoView = P2PPaymentsPayoutPersonalInfoView()
    private let payoutRequestView = P2PPaymentsPayoutRequestView()
    private let keyboardHelper = KeyboardHelper()
    private var personalInfoBottomContraint: NSLayoutConstraint?
    private var payoutRequestBottomContraint: NSLayoutConstraint?

    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
        return view
    }()

    init(viewModel: P2PPaymentsPayoutViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupKeyboardHelper()
    }

    private func setupNavigationBar() {
        setNavBarCloseButton(#selector(closeButtonPressed), icon: R.Asset.P2PPayments.close.image)
        setNavBarTitleStyle(NavBarTitleStyle.text(R.Strings.paymentPayoutNavbarTitle))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
    }

    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    private func setup() {
        view.backgroundColor = UIColor.white
        view.addSubviewsForAutoLayout([personalInfoView,
                                       payoutRequestView,
                                       activityIndicator])
        personalInfoView.isHidden = true
        payoutRequestView.isHidden = true
        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        personalInfoBottomContraint = personalInfoView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        personalInfoBottomContraint?.isActive = true
        payoutRequestBottomContraint = payoutRequestView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        payoutRequestBottomContraint?.isActive = true
        NSLayoutConstraint.activate([
            personalInfoView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            personalInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            personalInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            payoutRequestView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            payoutRequestView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            payoutRequestView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupRx() {
        let bindings = [
            viewModel.showLoadingIndicator.drive(activityIndicator.rx.isAnimating),
            viewModel.registerIsHidden.drive(personalInfoView.rx.isHidden),
            viewModel.payoutIsHidden.drive(payoutRequestView.rx.isHidden),
            viewModel.feeText.drive(payoutRequestView.rx.instantPaymentFeeText),
            viewModel.instantFundsAvailableText.drive(payoutRequestView.rx.instantFundsAvailableText),
            viewModel.standardFundsAvailableText.drive(payoutRequestView.rx.cardStandardFundsAvailableText),
            viewModel.standardFundsAvailableText.drive(payoutRequestView.rx.bankAccountStandardFundsAvailableText),
        ]
        bindings.forEach { [disposeBag] in $0.disposed(by: disposeBag) }

        personalInfoView.rx.registerButtonTap.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            let params = strongSelf.personalInfoView.registrationParams
            strongSelf.viewModel.registerButtonPressed(params: params)
        }).disposed(by: disposeBag)

        payoutRequestView.rx.bankAccountPayoutButtonTap.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            let params = strongSelf.payoutRequestView.bankAccountPayoutParams
            strongSelf.viewModel.payoutButtonPressed(params: params)
        }).disposed(by: disposeBag)

        payoutRequestView.rx.cardPayoutButtonTap.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            let params = strongSelf.payoutRequestView.cardPayoutParams
            strongSelf.viewModel.payoutButtonPressed(params: params)
        }).disposed(by: disposeBag)
    }

    private func setupKeyboardHelper() {
        keyboardHelper
            .rx_keyboardHeight
            .asDriver()
            .skip(1)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] height in
                self?.personalInfoBottomContraint?.constant = -height
                self?.payoutRequestBottomContraint?.constant = -height
                self?.view.layoutIfNeeded()
            }).disposed(by: disposeBag)
        keyboardHelper.rx_keyboardVisible.asDriver().drive(onNext: { [weak self] isVisible in
            guard !isVisible else { return }
            self?.personalInfoBottomContraint?.constant = 0
            self?.payoutRequestBottomContraint?.constant = 0
            self?.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
    }
}
