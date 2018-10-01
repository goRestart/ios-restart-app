import Foundation
import RxSwift
import LGComponents
import IGListKit
import LGCoreKit

final class FeedViewController: BaseViewController {
    private enum Layout {
        enum TabBarIcons {
            static let avatarSize = CGSize(width: 26, height: 26)
        }
    }
    
    private let refreshControl = UIRefreshControl()
    private let waterFallLayout = LGWaterFallLayout()
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
                                                    waterfallColumnCount: viewModel.waterfallColumnCount)
        waterFallAdapter.dataSource = self
        waterFallAdapter.collectionView = collectionView
        waterFallAdapter.scrollDelegate = self
        return waterFallAdapter
    }()

    private let viewModel: FeedViewModelType
    private let navbarSearch: LGNavBarSearchField?
    
    private let disposeBag = DisposeBag()

    private var hideSearchBox = false
    private var showRightButtons = true
    
    // MARK:- Init
    
    required init(withViewModel viewModel: BaseViewModel & FeedViewModelType,
                  hideSearchBox: Bool = false,
                  showRightNavBarButtons: Bool = true) {
        self.navbarSearch = hideSearchBox ? nil : LGNavBarSearchField(
            viewModel.searchString)
        self.viewModel = viewModel
        self.hideSearchBox = hideSearchBox
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.feedRenderingDelegate = self
        viewModel.delegate = self
        viewModel.rootViewController = self
        showRightButtons = showRightNavBarButtons
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
        setupRxBindings()
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

    private func setupNavBar() {
        defer {
            if showRightButtons { setupRightNavBarButtons() }
            setupInviteNavBarButton()
            setLeftNavBarButtons()
        }
        
        guard hideSearchBox else {
            if let safeNavbarSearch = navbarSearch {
                setNavBarTitleStyle(.custom(safeNavbarSearch))
                safeNavbarSearch.searchTextField.delegate = self
            }
            return
        }
        
        setNavBarTitleStyle(.text(viewModel.searchString))
    }
    
    private func setupRxBindings() {
        viewModel
            .rx_userAvatar
            .asDriver()
            .drive(onNext:{ [weak self] image in
                self?.setLeftNavBarButtons(withAvatar: image)
            })
            .disposed(by: disposeBag)

        viewModel
            .rx_updateAffiliate
            .drive(onNext:{ [weak self] image in
               self?.setupNavBar()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupRightNavBarButtons() {
        var buttonImages: [ButtonImage] = []
        var selectors: [Selector] = []
        
        let filterButtonImages = ButtonImage(normal: R.Asset.IconsButtons.icFilters.image, selected: R.Asset.IconsButtons.icFiltersActive.image)
            buttonImages.append(filterButtonImages)
            selectors.append(#selector(filtersButtonPressed))
        if viewModel.shouldShowAffiliateButton {
            let affiliateButtonImages =  ButtonImage(normal: R.Asset.Affiliation.affiliationIcon.image.tint(color: UIColor.primaryColor))
            buttonImages.append(affiliateButtonImages)
            selectors.append(#selector(AffiliationButtonPressed))
        }
        guard let filterButton = setLetGoRightButtonsWith(buttonImages: buttonImages,
                                                         selectors: selectors).first else { return }
        viewModel
            .rxHasFilter
            .drive(onNext: { filterButton.isSelected = $0})
            .disposed(by: disposeBag)
    }
    
    private func setupInviteNavBarButton() {
        guard viewModel.shouldShowInviteButton  else { return }

        let invite = UIBarButtonItem(title: R.Strings.mainProductsInviteNavigationBarButton,
                                     style: .plain,
                                     target: self,
                                     action: #selector(openInvite))
        let spacing = makeSpacingButton(withFixedWidth: Metrics.navBarDefaultSpacing)
        navigationItem.setLeftBarButtonItems([invite, spacing], animated: false)
    }
    
    private func removeLeftNavBarButton() {
        navigationItem.leftBarButtonItems = []
    }

    private func setLeftNavBarButtons(withAvatar avatar: UIImage? = nil) {
        guard isRootViewController() else { return }
        removeLeftNavBarButton()
        if viewModel.shouldShowCommunityButton {
            setCommunityButton()
        } else if viewModel.shouldShowUserProfileButton {
            setUserProfileButton(withAvatar: avatar)
        } else {
            setupInviteNavBarButton()
        }
    }
    
    private func setCommunityButton() {
        let button = UIBarButtonItem(image: R.Asset.IconsButtons.tabbarCommunity.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapCommunity))
        navigationItem.setLeftBarButton(button, animated: false)
    }
    
    private func setUserProfileButton(withAvatar avatar: UIImage?) {
        let image = avatar?.af_imageScaled(to: Layout.TabBarIcons.avatarSize)
            .af_imageRoundedIntoCircle()
            .withRenderingMode(.alwaysOriginal)
            ?? R.Asset.IconsButtons.tabbarProfile.image
        
        let button = UIBarButtonItem(image: image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapUserProfile))
        navigationItem.setLeftBarButton(button, animated: false)
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
            self?.viewModel.resetFirstLoadState()
            self?.loadFeed()
        }
        errorViewController = errorVC
        add(childViewController: errorVC)
    }
    
    private func refreshUIWithState(_ state: ViewState) {
        switch state {
        case .loading:
            guard !refreshControl.isRefreshing else { return }
            collectionView.isHidden = true
            add(childViewController: loadingViewController)
            errorViewController?.removeFromParent()
        case .data:
            collectionView.isHidden = false
            loadingViewController.removeFromParent()
            errorViewController?.removeFromParent()
            refreshControl.endRefreshing()
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
        navbarSearch?.set(accessibilityId: .feedNavBarSearch)
        navigationItem.leftBarButtonItem?.set(accessibilityId: .feedInviteButton)
    }
}

// MARK:- Scroll Delegates

extension FeedViewController: WaterFallScrollable {
    func willScroll(toSection section: Int) {
        viewModel.willScroll(toSection: section)
    }

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

// MARK: - Scrollable To Top

extension FeedViewController: ScrollableToTop {
    func scrollToTop() {
        collectionView.setContentOffset(.zero, animated: true)
    }
}

//  MARK: - UITextFieldDelegate

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
    
    @objc private func didTapCommunity() {
        viewModel.openCommunity()
    }
    
    @objc private func didTapUserProfile() {
        viewModel.openUserProfile()
    }
    
    @objc private func filtersButtonPressed(_ sender: AnyObject) {
        navbarSearch?.searchTextField.resignFirstResponder()
        viewModel.showFilters()
    }
    
    @objc private func AffiliationButtonPressed(_ sender: AnyObject) {
        viewModel.openAffiliationChallenges()
    }
    
    @objc private func refreshControlTriggered() {
        viewModel.refreshControlTriggered()
    }
}

extension FeedViewController: FeedRenderable {
    
    func convertViewRectInFeed(from originalFrame: CGRect) -> CGRect {
        return collectionView.convert(originalFrame, to: collectionView.superview)
    }
    
    func updateFeed(forceLayoutCalculation: Bool) {
        waterFallLayout.forceLayoutCalculation = forceLayoutCalculation
        adapter.performUpdates(animated: true, completion: nil)
    }
    
    func reloadFeed() {
        adapter.reloadData(completion: nil)
    }
}

extension FeedViewController: FeedViewModelDelegate {
    func vmDidUpdateState(_ vm: FeedViewModel, state: ViewState) {
        guard viewModel === vm else { return }
        refreshUIWithState(state)
    }
    
    func searchCompleted() { navbarSearch?.cancelEdit() }
}
