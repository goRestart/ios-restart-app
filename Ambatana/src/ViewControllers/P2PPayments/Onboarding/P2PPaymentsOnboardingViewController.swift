import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsOnboardingViewController: BaseViewController {
    private enum Layout {
        static let buttonHeight: CGFloat = 55
        static let buttonHorizontalMargin: CGFloat = 24
        static let buttonBottomMargin: CGFloat = 16
        static let stackViewMaxHeightDiff: CGFloat = 120
        static let stackViewWidthForPad: CGFloat = 414
    }

    private let traitsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 44, right: 0)
        return scrollView
    }()

    private let traitsStackView: UIStackView = {
        let firsTrait = P2PPaymentsOnboardingTraitView(title: "Make your offer",
                                                       subtitle: "You'll be charged and letgo will securely hold your funds in escrow until you confirm you've received the item",
                                                       image: R.Asset.P2PPayments.onboardingStep1.image)
        let secondTrait = P2PPaymentsOnboardingTraitView(title: "The seller accepts",
                                                         subtitle: "You’ll get a notification that the seller has accepted your offer",
                                                         image: R.Asset.P2PPayments.onboardingStep2.image)
        let thirdTrait = P2PPaymentsOnboardingTraitView(title: "Meet in person and release the payment",
                                                        subtitle: "When you have the item, release the payment to the seller",
                                                        image: R.Asset.P2PPayments.onboardingStep3.image)
        let stackView = UIStackView.vertical([firsTrait, secondTrait, thirdTrait])
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 22
        return stackView
    }()

    private lazy var makeAnOfferButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle("Make an offer", for: .normal)
        button.addTarget(self, action: #selector(makeAnOfferButtonPressed), for: .touchUpInside)
        return button
    }()

    var viewModel: P2PPaymentsOnboardingViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: P2PPaymentsOnboardingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        view = UIView()
        setupUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    private func setupUI() {
        view.addSubviewsForAutoLayout([traitsScrollView, makeAnOfferButton])
        traitsScrollView.addSubviewForAutoLayout(traitsStackView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            traitsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            traitsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            traitsScrollView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            traitsScrollView.bottomAnchor.constraint(equalTo: makeAnOfferButton.topAnchor),

            makeAnOfferButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.buttonHorizontalMargin),
            makeAnOfferButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.buttonHorizontalMargin),
            makeAnOfferButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -Layout.buttonBottomMargin),
            makeAnOfferButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),

            traitsStackView.leadingAnchor.constraint(equalTo: traitsScrollView.leadingAnchor),
            traitsStackView.trailingAnchor.constraint(equalTo: traitsScrollView.trailingAnchor),
            traitsStackView.topAnchor.constraint(equalTo: traitsScrollView.topAnchor),
            traitsStackView.bottomAnchor.constraint(equalTo: traitsScrollView.bottomAnchor),
            traitsStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            traitsStackView.heightAnchor.constraint(greaterThanOrEqualTo: traitsScrollView.heightAnchor, constant: -Layout.stackViewMaxHeightDiff),
        ])
    }

    private func setupNavigationBar() {
        setNavBarCloseButton(#selector(closeButtonPressed), icon: R.Asset.P2PPayments.close.image)
        setNavBarTitleStyle(NavBarTitleStyle.text("How it works"))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
    }

    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    @objc private func makeAnOfferButtonPressed() {
        viewModel.makeAnOfferButtonPressed()
    }
}
