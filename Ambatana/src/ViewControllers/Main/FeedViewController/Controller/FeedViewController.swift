import Foundation
import RxSwift
import LGComponents
import IGListKit
import LGCoreKit

final class FeedViewController: BaseViewController {
    
    
    private let refreshControl = UIRefreshControl()
    private let waterFallLayout = WaterFallLayout()
    private lazy var loadingViewController = LoadingViewController()
    private var errorViewController: ErrorViewController?
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: waterFallLayout)
        cv.backgroundColor = .grayBackground
        cv.showsVerticalScrollIndicator = true
        cv.alwaysBounceVertical = true
        return cv
    }()

    lazy var adapter: WaterFallListAdapter = {
        let waterFallAdapter = WaterFallListAdapter(updater: ListAdapterUpdater(),
                                                    viewController: self,
                                                    workingRangeSize: 0,
                                                    numberOfColumnsInLastSection: viewModel.numberOfColumnsInLastSection)
        waterFallAdapter.dataSource = self
        waterFallAdapter.collectionView = collectionView
        waterFallAdapter.scrollDelegate = self
        return waterFallAdapter
    }()

    private let viewModel: FeedViewModelType
    private let navbarSearch: LGNavBarSearchField
    
    private let disposeBag = DisposeBag()

    
    // MARK:- Init
    
    required init<T>(withViewModel viewModel: T) where T: BaseViewModel, T: FeedViewModelType {
        self.navbarSearch = LGNavBarSearchField(viewModel.searchString)
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.feedRenderingDelegate = self
        viewModel.delegate = self
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    
    // MARK:- View Life Cycle

    override func loadView() {
        super.loadView()
        addCollectionView()
        refreshUIWithState(viewModel.viewState)
        loadFeed()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
        setupRefreshControl()
        setAccessibilityIds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRefreshControlBounds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setBars(hidden: false)
    }
    
    
    // MARK:- Private Methods
    
    private func loadFeed() {
        viewModel.loadFeedItems()
    }

    private func addCollectionView() {
        view.addSubviewForAutoLayout(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
            collectionView.topAnchor.constraint(equalTo: isSafeAreaAvailable ? safeTopAnchor : view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.contentInset.bottom = tabBarHeight
            + LGUIKitConstants.tabBarSellFloatingButtonHeight
            + LGUIKitConstants.tabBarSellFloatingButtonDistance
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: UIControlEvents.valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
    }
    
    private func setupRefreshControlBounds() {
        let origin = CGPoint(x: refreshControl.bounds.origin.x,
                             y: -waterFallLayout.refreshControlOriginY())
        refreshControl.bounds = CGRect(origin: origin, size: refreshControl.intrinsicContentSize)
    }

    private func setupNavBar() {
        setNavBarTitleStyle(.custom(navbarSearch))
        navbarSearch.searchTextField.delegate = self
        setupFiltersButton()
        setupInviteNavBarButton()
    }

    private func setupFiltersButton() {
        let buttonImages = ButtonImage(normal: R.Asset.IconsButtons.icFilters.image, selected: R.Asset.IconsButtons.icFiltersActive.image)
        guard let rightButton = setLetGoRightButtonsWith(buttonImages: [buttonImages],
                                                         selectors: [#selector(filtersButtonPressed)]).first else { return  }
        viewModel
            .rxHasFilter
            .drive(onNext: { rightButton.isSelected = $0})
            .disposed(by: disposeBag)
    }
    
    private func setupInviteNavBarButton() {
        guard isRootViewController() else { return }
        guard viewModel.shouldShowInviteButton  else { return }

        let invite = UIBarButtonItem(title: R.Strings.mainProductsInviteNavigationBarButton,
                                     style: .plain,
                                     target: self,
                                     action: #selector(openInvite))
        let spacing = makeSpacingButton(withFixedWidth: Metrics.navBarDefaultSpacing)
        navigationItem.setLeftBarButtonItems([invite, spacing], animated: false)
    }

    private func setup() {
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
        automaticallyAdjustsScrollViewInsets = false
    }
    
    private func setBars(hidden: Bool, animated: Bool = true) {
        tabBarController?.setTabBarHidden(hidden, animated: animated)
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }
    
    private func addErrorViewController(with emptyVM: LGEmptyViewModel) {
        let errorVC = ErrorViewController(style: .feed, viewModel: emptyVM)
        errorVC.retryHandler = { [weak self] in
            self?.loadFeed()
        }
        errorViewController = errorVC
        add(childViewController: errorVC)
    }
    
    private func refreshUIWithState(_ state: ViewState) {
        switch (state) {
        case .loading:
            collectionView.isHidden = true
            add(childViewController: loadingViewController)
            errorViewController?.removeFromParent()
        case .data:
            collectionView.isHidden = false
            loadingViewController.removeFromParent()
            errorViewController?.removeFromParent()
        case .error(let emptyVM):
            collectionView.isHidden = true
            loadingViewController.removeFromParent()
            addErrorViewController(with: emptyVM)
        case .empty(let emptyVM):
            collectionView.isHidden = false
            loadingViewController.removeFromParent()
            addErrorViewController(with: emptyVM)
        }
    }
}

extension FeedViewController: ListAdapterDataSource {

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModel.feedItems
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return viewModel.feedSectionController(for: object)
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension FeedViewController {
    func setAccessibilityIds() {
        navigationItem.rightBarButtonItem?.set(accessibilityId: .feedFilterButton)
        collectionView.set(accessibilityId: .feedCollectionView)
        navbarSearch.set(accessibilityId: .feedNavBarSearch)
        navigationItem.leftBarButtonItem?.set(accessibilityId: .feedInviteButton)
    }
}


// MARK:- Scroll Delegates

extension FeedViewController: WaterFallScrollable {
    
    /// Return true if user scrolls with finger moving downwards
    private func scrollViewIsScrollingDown(_ scrollView: UIScrollView) -> Bool {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        return translation.y > 0
    }
    
    func didScroll(_ scrollView: UIScrollView) {
        if collectionView.contentOffset.y == 0 {
            setBars(hidden: false)
        } else {
            setBars(hidden: !scrollViewIsScrollingDown(scrollView))
        }
    }
}

extension FeedViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel.openSearches()
        textField.resignFirstResponder()
    }
}

// MARK:- Actions

extension FeedViewController {

    @objc private func openInvite() {
        viewModel.openInvite()
    }
    
    @objc private func filtersButtonPressed(_ sender: AnyObject) {
        navbarSearch.searchTextField.resignFirstResponder()
        viewModel.showFilters()
    }
    
    @objc private func refreshControlTriggered() {
        viewModel.refreshControlTriggered()
        // FIXME: Delete this dispatch logic once refresh control logic is implemented
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

extension FeedViewController: FeedRenderable {
    func updateFeed() {
        adapter.performUpdates(animated: true, completion: nil)
    }
}

extension FeedViewController: FeedViewModelDelegate {
    func vmDidUpdateState(_ vm: FeedViewModel, state: ViewState) {
        guard viewModel === vm else { return }
        refreshUIWithState(state)
    }
}
