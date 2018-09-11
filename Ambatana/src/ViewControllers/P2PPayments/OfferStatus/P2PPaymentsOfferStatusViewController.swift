import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsOfferStatusViewController: BaseViewController {
    private enum Layout {
        static let contentHorizontalMargin: CGFloat = 24
        static let separatorHorizontalMargin: CGFloat = 12
        static let buttonHeight: CGFloat = 55
        static let buttonBottomMargin: CGFloat = 16
        static let headerTopMargin: CGFloat = 4
        static let separatorTopMargin: CGFloat = 24
        static let separatorBottomMargin: CGFloat = 12
    }

    private let headerView = P2PPaymentsListingHeaderView()
    private let lineSeparatorView = P2PPaymentsLineSeparatorView()
    private let stepListView = P2PPaymentsOfferStatusStepListView()
    private let actionButton = LetgoButton(withStyle: .primary(fontSize: .big))

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

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
        view.addSubviewsForAutoLayout([headerView, lineSeparatorView, scrollView, actionButton, activityIndicator])
        scrollView.addSubviewForAutoLayout(stepListView)
        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: Layout.headerTopMargin),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.contentHorizontalMargin),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.contentHorizontalMargin),

            lineSeparatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Layout.separatorTopMargin),
            lineSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.separatorHorizontalMargin),
            lineSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.separatorHorizontalMargin),

            stepListView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2 * Layout.contentHorizontalMargin),
            stepListView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Layout.contentHorizontalMargin),
            stepListView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Layout.contentHorizontalMargin),
            stepListView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stepListView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: lineSeparatorView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.contentHorizontalMargin),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.contentHorizontalMargin),
            actionButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            actionButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -Layout.buttonBottomMargin),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupRx() {
        let bindings = [
            viewModel.showLoadingIndicator.drive(activityIndicator.rx.isAnimating),
            viewModel.listingImageURL.drive(headerView.rx.imageURL),
            viewModel.listingTitle.drive(headerView.rx.title),
            viewModel.stepList.map { $0 ?? .empty }.drive(stepListView.rx.state),
            viewModel.actionButtonTitle.drive(actionButton.rx.title()),
            viewModel.actionButtonTitle.map { $0 == nil }.drive(actionButton.rx.isHidden),
        ]
        bindings.forEach { [disposeBag] in $0.disposed(by: disposeBag) }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset: CGFloat = {
            guard !actionButton.isHidden else { return 0 }
            return view.bounds.maxY - actionButton.frame.minY
        }()
        scrollView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: bottomInset, right: 0)
    }
}
