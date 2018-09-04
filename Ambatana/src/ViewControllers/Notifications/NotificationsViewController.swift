import UIKit
import RxSwift
import LGComponents

final class NotificationsViewController: BaseViewController {

    weak var tabNavigator: TabNavigator?
    
    private let viewModel: NotificationsViewModel
    private let disposeBag = DisposeBag()
    private let notificationsView = NotificationsView()
    
    override func loadView() {
        self.view = notificationsView
    }
    
    init(viewModel: NotificationsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRX()
    }
 
    // MARK: - Private methods
    
    private func setupUI() {
        setNavBarTitle(R.Strings.notificationsTitle)
        notificationsView.configure(with: viewModel)
    }
    
    private func setupRX() {
        viewModel.viewState.asDriver()
            .drive(notificationsView.rx.state)
            .disposed(by: disposeBag)
    }
}

// MARK: - Scrollable to top

extension NotificationsViewController: ScrollableToTop {
    func scrollToTop() {
        notificationsView.scrollToTop()
    }
}
