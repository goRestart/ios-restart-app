import UIKit
import LGComponents
import RxSwift
import RxCocoa
import PassKit

// TODO: @juolgon Locaalize all texts

final class P2PPaymentsCreateOfferViewController: BaseViewController {
    var viewModel: P2PPaymentsCreateOfferViewModel

    private let headerView = P2PPaymentsListingHeaderView()
    private let lineSeparatorView = P2PPaymentsLineSeparatorView()
    private let changeOfferView = P2PPaymentsChangeOfferView()
    private let buyerInfoView = P2PPaymentsCreateOfferBuyerInfoView()
    private let setupPaymentButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .whiteOutline)
    private let buyButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
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

    override func loadView() {
        view = UIView()
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }

    private func setup() {
        view.addSubviewsForAutoLayout([headerView, lineSeparatorView, changeOfferView, buyerInfoView, setupPaymentButton, buyButton, activityIndicator])
        setupConstraints()
        setupKeyboardHelper()
        hideAllViews()
    }

    private func setupConstraints() {
        bottomContraint = changeOfferView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 4),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            lineSeparatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            lineSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            lineSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            buyerInfoView.topAnchor.constraint(equalTo: lineSeparatorView.bottomAnchor, constant: 12),
            buyerInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buyerInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            changeOfferView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            changeOfferView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            changeOfferView.topAnchor.constraint(equalTo: lineSeparatorView.bottomAnchor, constant: 12),
            bottomContraint!,

            setupPaymentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            setupPaymentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            setupPaymentButton.heightAnchor.constraint(equalToConstant: 44),
            setupPaymentButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -16),

            buyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buyButton.heightAnchor.constraint(equalToConstant: 44),
            buyButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -16),

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

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        setNavBarCloseButton(#selector(closeButtonPressed), icon: R.Asset.P2PPayments.close.image)
        setNavBarTitleStyle(NavBarTitleStyle.text("Offer"))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
    }

    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
}
