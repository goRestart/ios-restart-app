import UIKit
import LGComponents
import RxSwift
import RxCocoa
import PassKit


final class P2PPaymentsCreateOfferViewController: BaseViewController {
    private enum Layout {
        static let contentHorizontalMargin: CGFloat = 24
        static let separatorHorizontalMargin: CGFloat = 12
        static let buttonHeight: CGFloat = 44
        static let buttonBottomMargin: CGFloat = 16
        static let headerTopMargin: CGFloat = 4
        static let separatorTopMargin: CGFloat = 24
        static let separatorBottomMargin: CGFloat = 12
    }

    private let viewModel: P2PPaymentsCreateOfferViewModel
    private let headerView = P2PPaymentsListingHeaderView()
    private let lineSeparatorView = P2PPaymentsLineSeparatorView()
    private let changeOfferView = P2PPaymentsChangeOfferView()
    private let buyerInfoView = P2PPaymentsCreateOfferBuyerInfoView()
    private let setupPaymentButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .whiteOutline)
    private let buyButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()

    private var bottomContraint: NSLayoutConstraint?
    private let keyboardHelper = KeyboardHelper()
    private let disposeBag = DisposeBag()

    init(viewModel: P2PPaymentsCreateOfferViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setup()
    }

    private func setup() {
        view.addSubviewsForAutoLayout([headerView, lineSeparatorView, changeOfferView, buyerInfoView, setupPaymentButton, buyButton, activityIndicator])
        setupConstraints()
        setupKeyboardHelper()
        hideAllViews()
        setupRx()
    }

    private func setupConstraints() {
        bottomContraint = changeOfferView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        bottomContraint?.isActive = true
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: Layout.headerTopMargin),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.contentHorizontalMargin),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.contentHorizontalMargin),

            lineSeparatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Layout.separatorTopMargin),
            lineSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.separatorHorizontalMargin),
            lineSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.separatorHorizontalMargin),

            buyerInfoView.topAnchor.constraint(equalTo: lineSeparatorView.bottomAnchor, constant: Layout.separatorBottomMargin),
            buyerInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buyerInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            changeOfferView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            changeOfferView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            changeOfferView.topAnchor.constraint(equalTo: lineSeparatorView.bottomAnchor, constant: Layout.separatorBottomMargin),

            setupPaymentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.contentHorizontalMargin),
            setupPaymentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.contentHorizontalMargin),
            setupPaymentButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            setupPaymentButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -Layout.buttonBottomMargin),

            buyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.contentHorizontalMargin),
            buyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.contentHorizontalMargin),
            buyButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            buyButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -Layout.buttonBottomMargin),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupKeyboardHelper() {
        keyboardHelper
            .rx_keyboardHeight
            .asDriver()
            .skip(1)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] height in
                self?.bottomContraint?.constant = -height
                self?.view.layoutIfNeeded()
            }).disposed(by: disposeBag)
    }

    private func hideAllViews() {
        buyerInfoView.isHidden = true
        changeOfferView.isHidden = true
        setupPaymentButton.isHidden = true
        buyButton.isHidden = true
    }

    private func setupRx() {
        let bindings = [
            viewModel.listingImageViewURL.drive(headerView.rx.imageURL),
            viewModel.listingTitle.drive(headerView.rx.title),
            viewModel.priceAmountText.drive(buyerInfoView.rx.priceText),
            viewModel.feeAmountText.drive(buyerInfoView.rx.feeText),
            viewModel.totalAmountText.drive(buyerInfoView.rx.totalText),
            viewModel.feePercentageText.drive(buyerInfoView.rx.feePercentageText),
            viewModel.uiState.map { $0 == .loading }.drive(activityIndicator.rx.isAnimating),
            viewModel.uiState.map { $0 != .buy }.drive(buyerInfoView.rx.isHidden),
            viewModel.uiState.map { $0 != .changeOffer }.drive(changeOfferView.rx.isHidden),
            viewModel.uiState.map { $0 == .changeOffer }.drive(changeOfferView.rx.isFocused),
            viewModel.currencyCode.drive(changeOfferView.rx.currencyCode),
            viewModel.offerAmount.drive(changeOfferView.rx.value),
            viewModel.buyButtonHidden.drive(buyButton.rx.isHidden),
            viewModel.configurePaymentButtonHidden.drive(setupPaymentButton.rx.isHidden),
        ]
        bindings.forEach { [disposeBag] in $0.disposed(by: disposeBag) }

        viewModel.paymentAuthController
            .drive(onNext: { [weak self] controller in
                guard let controller = controller else { return }
                self?.present(controller, animated: true)
            })
            .disposed(by: disposeBag)

        buyerInfoView.rx.changeButtonTap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.changeOfferButtonPressed()
            })
            .disposed(by: disposeBag)

        changeOfferView.rx.changeOfferButtonTap
            .subscribe(onNext: { [weak self] _ in
                guard let newValue = self?.changeOfferView.value else { return }
                self?.changeOfferView.endEditing(true)
                self?.viewModel.changeOfferDoneButtonPressed(newValue: newValue)
            })
            .disposed(by: disposeBag)

        setupPaymentButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.configurePaymentButtonPressed()
            })
            .disposed(by: disposeBag)

        buyButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.payButtonPressed()
            })
            .disposed(by: disposeBag)
        viewModel.offerAmountState.filter { $0 == .invalid }
            .drive(onNext: { [weak self] state in
                self?.showInvalidAmountAlert()
            })
            .disposed(by: disposeBag)

    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        setNavBarCloseButton(#selector(closeButtonPressed), icon: R.Asset.P2PPayments.close.image)
        setNavBarTitleStyle(NavBarTitleStyle.text(R.Strings.paymentsCreateOfferNavbarTitle))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
    }

    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    private func showInvalidAmountAlert() {
        vmShowAlert(nil, message: viewModel.invalidAmountMessage,
                    cancelLabel: R.Strings.paymentsChangeOfferInvalidAmountAlertButton,
                    actions: [])
    }
}
