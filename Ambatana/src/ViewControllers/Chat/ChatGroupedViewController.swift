import LGCoreKit
import RxCocoa
import RxSwift
import UIKit
import LGComponents

class ChatGroupedViewController: BaseViewController, ChatGroupedListViewDelegate,
                                 ChatListViewDelegate, BlockedUsersListViewDelegate, LGViewPagerDataSource,
                                 LGViewPagerDelegate, ScrollableToTop, ChatGroupedViewModelDelegate {
    // UI
    var viewPager: LGViewPager
    var validationPendingEmptyView: LGEmptyView = LGEmptyView()

    private var statusViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private let connectionStatusView = ChatConnectionStatusView()

    // Data
    fileprivate let viewModel: ChatGroupedViewModel
    private var pages: [BaseView]

    // Rx
    let disposeBag: DisposeBag
    
    // FeatureFlags
    private let featureFlags: FeatureFlaggeable


    // MARK: - Lifecycle

    init(viewModel: ChatGroupedViewModel, featureFlags: FeatureFlaggeable) {
        self.featureFlags = featureFlags
        self.viewModel = viewModel
        self.viewPager = LGViewPager()
        self.pages = []
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
        
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false
        hasTabBar = true

        self.showConnectionToastView = !featureFlags.showChatConnectionStatusBar.isActive

        for index in 0..<viewModel.chatListsCount {
            let page: ChatListView
            
            guard let pageVM = viewModel.chatListViewModelForTabAtIndex(index) else { continue }
            page = ChatListView(viewModel: pageVM)
            page.tableView.set(accessibilityId: viewModel.accessibilityIdentifierForTableViewAtIndex(index))
            page.footerButton.set(accessibilityId: .chatListViewFooterButton)
            page.chatGroupedListViewDelegate = self
            page.delegate = self
            pages.append(page)
        }
        
        let pageVM = viewModel.blockedUsersListViewModel
        let page = BlockedUsersListView(viewModel: pageVM)
        page.chatGroupedListViewDelegate = self
        page.blockedUsersListViewDelegate = self
        pages.append(page)
        
        setupRxBindings()
    }
    
    convenience init(viewModel: ChatGroupedViewModel) {
        self.init(viewModel: viewModel, featureFlags: FeatureFlags.sharedInstance)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            setupCancelNavigationsBarButton()
        } else {
            setupMoreOptionsNavigationsBarButton()
        }
        viewModel.setCurrentPageEditing(editing)
        if viewModel.active {
            tabBarController?.setTabBarHidden(editing, animated: true)
        }
        viewPager.scrollEnabled = !editing
    }
    
    @objc func switchEditing() {
        setEditing(!isEditing, animated: true)
    }

    override var active: Bool {
        didSet {
            pages.forEach { $0.active = active }
        }
    }


    // MARK: - ChatGroupedListViewDelegate

    func chatGroupedListViewShouldUpdateInfoIndicators() {
        viewPager.reloadInfoIndicatorState()
    }


    // MARK: - ChatListViewDelegate

    func chatListView(_ chatListView: ChatListView, showDeleteConfirmationWithTitle title: String, message: String,
        cancelText: String, actionText: String, action: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
        let archiveAction = UIAlertAction(title: actionText, style: .destructive) { (_) -> Void in
            action()
        }
        alert.addAction(cancelAction)
        alert.addAction(archiveAction)
        present(alert, animated: true, completion: nil)
    }

    func chatListViewDidStartArchiving(_ chatListView: ChatListView) {
        showLoadingMessageAlert()
    }

    func chatListView(_ chatListView: ChatListView, didFinishArchivingWithMessage message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message: message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }

    func chatListView(_ chatListView: ChatListView, didFinishUnarchivingWithMessage message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message: message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }


    // MARK: - BlockedUsersListViewDelegate

    func didSelectBlockedUser(_ user: User) {
        viewModel.blockedUserPressed(user)
    }

    func didStartUnblocking() {
        showLoadingMessageAlert()
    }

    func didFinishUnblockingWithMessage(_ message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message: message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }


    // MARK: - LGViewPagerDataSource

    func viewPagerNumberOfTabs(_ viewPager: LGViewPager) -> Int {
        return viewModel.tabCount
    }

    func viewPager(_ viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        return pages[index]
    }

    func viewPager(_ viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool {
        return viewModel.showInfoBadgeAtIndex(index)
    }

    func viewPager(_ viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        return viewModel.titleForTabAtIndex(index, selected: false)
    }

    func viewPager(_ viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        return viewModel.titleForTabAtIndex(index, selected: true)
    }
    
    func viewPager(_ viewPager: LGViewPager, accessibilityIdentifierAtIndex index: Int) -> AccessibilityId? {
        return viewModel.accessibilityIdentifierForTabButtonAtIndex(index)
    }


    // MARK: - LGViewPagerDelegate

    func viewPager(_ viewPager: LGViewPager, willDisplayView view: UIView, atIndex index: Int) {
        if let tab = ChatGroupedViewModel.Tab(rawValue: index) {
            viewModel.currentTab.value = tab
        }
        if isEditing {
            setEditing(false, animated: true)
        }
        viewModel.refreshCurrentPage()
    }

    func viewPager(_ viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {

    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        guard viewPager.currentPage < pages.count else { return }

        if let scrollable = pages[viewPager.currentPage] as? ScrollableToTop {
            scrollable.scrollToTop()
        }
    }

    // MARK: - Actions
    
    @objc func moreOptionsButtonPressed() {
        viewModel.openMenuActionSheet()
    }

    // MARK: - Private methods

    private func setupUI() {
        setupValidationEmptyState()

        view.backgroundColor = UIColor.listBackgroundColor
        setNavBarTitle(R.Strings.chatListTitle)
        setupMoreOptionsNavigationsBarButton()
        
        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.indicatorSelectedColor = UIColor.primaryColor
        viewPager.infoBadgeColor = UIColor.primaryColor
        viewPager.tabsSeparatorColor = UIColor.lineGray
        view.addSubviewForAutoLayout(viewPager)

        viewPager.reloadData()
    }

    private func setupValidationEmptyState() {
        guard let emptyVM = viewModel.verificationPendingEmptyVM else { return }
        validationPendingEmptyView.setupWithModel(emptyVM)
        validationPendingEmptyView.frame = view.frame
        view.addSubview(validationPendingEmptyView)
    }

    private func setupConstraints() {
        if featureFlags.showChatConnectionStatusBar.isActive {
            view.addSubviewForAutoLayout(connectionStatusView)
            statusViewHeightConstraint = connectionStatusView.heightAnchor.constraint(equalToConstant: 0)
            let connectionStatusViewTopConstraint: NSLayoutConstraint
            if #available(iOS 11, *) {
                connectionStatusViewTopConstraint = connectionStatusView.topAnchor
                    .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            } else {
                connectionStatusViewTopConstraint = connectionStatusView
                    .topAnchor
                    .constraint(equalTo: topLayoutGuide.bottomAnchor)
            }
            NSLayoutConstraint.activate([
                statusViewHeightConstraint,
                connectionStatusViewTopConstraint,
                connectionStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                connectionStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                viewPager.topAnchor.constraint(equalTo: connectionStatusView.bottomAnchor),
                viewPager.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                viewPager.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                viewPager.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        } else {
            let viewPagerTopConstraint: NSLayoutConstraint
            if #available(iOS 11, *) {
                viewPagerTopConstraint = viewPager.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            } else {
                viewPagerTopConstraint = viewPager
                    .topAnchor
                    .constraint(equalTo: topLayoutGuide.bottomAnchor)
            }
            NSLayoutConstraint.activate([
                viewPagerTopConstraint,
                viewPager.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                viewPager.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                viewPager.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        }
    }
    
    private func setupMoreOptionsNavigationsBarButton() {
        setLetGoRightButtonWith(image: R.Asset.IconsButtons.icMoreOptions.image, selector: "moreOptionsButtonPressed")
    }
    
    private func setupCancelNavigationsBarButton() {
        setLetGoRightButtonWith(text: R.Strings.commonCancel, selector: #selector(switchEditing))
    }
    
    // MARK: - ChatGroupedViewModelDelegate
    
    func vmDidPressDelete() {
        setEditing(true, animated: true)
    }
}


// MARK: - Rx

extension ChatGroupedViewController {

    fileprivate func setupRxBindings() {
        setupRxVerificationViewBindings()
        setupConnectionStatusBarRx()
    }

    private func setupRxVerificationViewBindings() {
        viewModel.verificationPending.asObservable().bind(to: viewPager.rx.isHidden).disposed(by: disposeBag)
        viewModel.verificationPending.asObservable().map { !$0 }.bind(to: validationPendingEmptyView.rx.isHidden)
            .disposed(by: disposeBag)
    }

    private func setupConnectionStatusBarRx() {
        viewModel.rx_connectionBarStatus.asDriver().skip(1).drive(onNext: { [weak self] status in
            guard let _ = status.title else {
                self?.animateStatusBar(visible: false)
                return
            }
            self?.connectionStatusView.status = status
            self?.animateStatusBar(visible: true)
        }).disposed(by: disposeBag)
    }

    private func animateStatusBar(visible: Bool) {
        statusViewHeightConstraint.constant = visible ? ChatConnectionStatusView.standardHeight : 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatGroupedViewController {
    func setAccessibilityIds() {
        navigationItem.rightBarButtonItem?.set(accessibilityId: .chatGroupedViewRightNavBarButton)
    }
}
