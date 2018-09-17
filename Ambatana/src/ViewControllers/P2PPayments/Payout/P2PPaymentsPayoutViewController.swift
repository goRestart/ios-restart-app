import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsPayoutViewController: BaseViewController {
    private let viewModel: P2PPaymentsPayoutViewModel
    private let disposeBag = DisposeBag()

    private let personalInfoView = P2PPaymentsPayoutPersonalInfoView()

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

    private func setupNavigationBar() {
        setNavBarCloseButton(#selector(closeButtonPressed), icon: R.Asset.P2PPayments.close.image)
        setNavBarTitleStyle(NavBarTitleStyle.text("Payout"))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
    }

    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    private func setup() {
        view.backgroundColor = UIColor.white
        view.addSubviewForAutoLayout(personalInfoView)
        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        personalInfoView.constraintToEdges(in: view)
//        NSLayoutConstraint.activate([
//        ])
    }

    private func setupRx() {
    }
}
