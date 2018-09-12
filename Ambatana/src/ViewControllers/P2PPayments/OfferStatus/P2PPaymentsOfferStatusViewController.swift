import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsOfferStatusViewController: BaseViewController {

    private let offerStatusBuyer = P2PPaymentsOfferStatusBuyerView()
    private let offerStatusSeller = P2PPaymentsOfferStatusSellerView()
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()

    private let viewModel: P2PPaymentsOfferStatusViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: P2PPaymentsOfferStatusViewModel) {
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

    private func setupNavigationBar() {
        setNavBarCloseButton(#selector(closeButtonPressed), icon: R.Asset.P2PPayments.close.image)
        setNavBarTitleStyle(NavBarTitleStyle.text("Offer"))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
    }

    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    private func setup() {
        view.backgroundColor = UIColor.white
        view.addSubviewsForAutoLayout([offerStatusBuyer, offerStatusSeller, activityIndicator])
        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            offerStatusBuyer.topAnchor.constraint(equalTo: view.safeTopAnchor),
            offerStatusBuyer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            offerStatusBuyer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offerStatusBuyer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            offerStatusSeller.topAnchor.constraint(equalTo: view.safeTopAnchor),
            offerStatusSeller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            offerStatusSeller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offerStatusSeller.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupRx() {
        let bindings = [
            viewModel.showLoadingIndicator.drive(activityIndicator.rx.isAnimating),
            viewModel.hideBuyerInfo.drive(offerStatusBuyer.rx.isHidden),
            viewModel.hideSellerInfo.drive(offerStatusSeller.rx.isHidden),

            viewModel.listingImageURL.drive(offerStatusBuyer.rx.listingImageURL),
            viewModel.listingTitle.drive(offerStatusBuyer.rx.listingTitle),
            viewModel.buyerStepList.map { $0 ?? .empty }.drive(offerStatusBuyer.rx.stepList),
            viewModel.actionButtonTitle.drive(offerStatusBuyer.rx.actionButtonTitle),
            viewModel.actionButtonTitle.map { $0 == nil }.drive(offerStatusBuyer.rx.actionButtonIsHidden),

            viewModel.sellerStepList.map { $0 ?? .empty }.drive(offerStatusSeller.rx.stepList),
        ]
        bindings.forEach { [disposeBag] in $0.disposed(by: disposeBag) }
    }
}
