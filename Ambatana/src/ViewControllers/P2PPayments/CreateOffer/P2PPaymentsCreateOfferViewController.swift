import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Locaalize all texts

final class P2PPaymentsCreateOfferViewController: BaseViewController {
    var viewModel: P2PPaymentsCreateOfferViewModel

    private let headerView = P2PPaymentsListingHeaderView()
    private let lineSeparatorView = P2PPaymentsLineSeparatorView()
    private let changeOfferView = P2PPaymentsChangeOfferView()
    private let offerFeesView = P2PPaymentsOfferFeesView()

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
        view.addSubviewsForAutoLayout([headerView, lineSeparatorView, changeOfferView])
        setupConstraints()
        setupKeyboardHelper()
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

            changeOfferView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            changeOfferView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            changeOfferView.topAnchor.constraint(equalTo: lineSeparatorView.bottomAnchor, constant: 12),
            bottomContraint!
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
