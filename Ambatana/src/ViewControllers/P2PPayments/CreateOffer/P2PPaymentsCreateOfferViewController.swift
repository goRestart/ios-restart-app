import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Locaalize all texts

final class P2PPaymentsCreateOfferViewController: BaseViewController {
    var viewModel: P2PPaymentsCreateOfferViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: P2PPaymentsCreateOfferViewModel) {
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

    private func setupUI() {
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
}
