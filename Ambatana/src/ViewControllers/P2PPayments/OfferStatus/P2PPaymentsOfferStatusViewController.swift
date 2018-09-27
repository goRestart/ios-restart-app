import UIKit
import LGComponents
import RxSwift
import RxCocoa


final class P2PPaymentsOfferStatusViewController: BaseViewController {

    private let offerStatusBuyer = P2PPaymentsOfferStatusBuyerView()
    private let offerStatusSeller = P2PPaymentsOfferStatusSellerView()
    private let errorRetryView = P2PPaymentsErrorRetryView()
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()

    private lazy var optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Asset.P2PPayments.icOptions.image, for: .normal)
        button.addTarget(self, action: #selector(optionsButtonPressed), for: .touchUpInside)
        return button
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
        setNavBarTitleStyle(NavBarTitleStyle.text(R.Strings.paymentsOfferStatusNavbarTitle))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
        setNavigationBarRightButtons([optionsButton])
    }

    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    @objc private func optionsButtonPressed() {
        let contactUs = UIAction(interface: UIActionInterface.text(R.Strings.paymentsCommonContactUsOption),
                                 action: viewModel.contactUsActionSelected)
        let faqs = UIAction(interface: UIActionInterface.text(R.Strings.paymentsCommonFaqsOption),
                            action: viewModel.faqsActionSelected)
        vmShowActionSheet(R.Strings.commonCancel, actions: [contactUs, faqs])
    }

    private func setup() {
        view.backgroundColor = UIColor.white
        view.addSubviewsForAutoLayout([offerStatusBuyer, offerStatusSeller, activityIndicator, errorRetryView])
        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        errorRetryView.constraintToEdges(in: view)
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
            viewModel.hideErrorRetry.drive(errorRetryView.rx.isHidden),

            viewModel.listingImageURL.drive(offerStatusBuyer.rx.listingImageURL),
            viewModel.listingTitle.drive(offerStatusBuyer.rx.listingTitle),
            viewModel.buyerStepList.map { $0 ?? .empty }.drive(offerStatusBuyer.rx.stepList),
            viewModel.actionButtonTitle.drive(offerStatusBuyer.rx.actionButtonTitle),
            viewModel.actionButtonTitle.map { $0 == nil }.drive(offerStatusBuyer.rx.actionButtonIsHidden),

            viewModel.sellerHeaderImageURL.drive(offerStatusSeller.rx.buyerImageURL),
            viewModel.sellerHeaderTitle.drive(offerStatusSeller.rx.headerTitle),
            viewModel.netAmountText.drive(offerStatusSeller.rx.netText),
            viewModel.feeAmountText.drive(offerStatusSeller.rx.feeText),
            viewModel.grossAmountText.drive(offerStatusSeller.rx.grossText),
            viewModel.feePercentageText.drive(offerStatusSeller.rx.feePercentageText),
            viewModel.declineButtonIsHidden.drive(offerStatusSeller.rx.declineButtonIsHidden),
            viewModel.acceptButtonIsHidden.drive(offerStatusSeller.rx.acceptButtonIsHidden),
            viewModel.enterCodeButtonIsHidden.drive(offerStatusSeller.rx.enterCodeButtonIsHidden),
            viewModel.sellerStepList.map { $0 ?? .empty }.drive(offerStatusSeller.rx.stepList),
        ]
        bindings.forEach { [disposeBag] in $0.disposed(by: disposeBag) }

        offerStatusBuyer.rx.actionButtonTap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.actionButtonPressed()
            })
            .disposed(by: disposeBag)

        offerStatusSeller.rx.acceptButtonTap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.acceptButtonPressed()
            })
            .disposed(by: disposeBag)

        offerStatusSeller.rx.declineButtonTap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.declineButtonPressed()
            })
            .disposed(by: disposeBag)

        offerStatusSeller.rx.enterCodeButtonTap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.enterCodeButtonPressed()
            })
            .disposed(by: disposeBag)

        errorRetryView.rx.retryTap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.retryButtonPressed()
            })
            .disposed(by: disposeBag)
    }
}