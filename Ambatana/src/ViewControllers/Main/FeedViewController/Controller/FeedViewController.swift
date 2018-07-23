import Foundation
import RxSwift
import LGComponents

final class FeedViewController: BaseViewController {
    
    private let navbarSearch: LGNavBarSearchField
    private let refreshControl = UIRefreshControl()
    weak var collectionViewFooter: CollectionViewFooter?
    
    private let infoBubbleView = InfoBubbleView(style: .light)
    private var infoBubbleTopConstraints: NSLayoutConstraint?

    private let waterFallLayout = WaterFallLayout()
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.backgroundColor = .grayBackground
        cv.showsVerticalScrollIndicator = true
        return cv
    }()
    
    private let viewModel: FeedViewModelType
    private let disposeBag = DisposeBag()
    
    // MARK:- Init
    
    required init<T>(withViewModel viewModel: T) where T: BaseViewModel, T: FeedViewModelType {
        self.navbarSearch = LGNavBarSearchField(viewModel.searchString)
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    
    // MARK:- View Life Cycle

    override func loadView() {
        super.loadView()
        addCollectionView()
        addInfoBubbleView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
        setupRefreshControl()
        setAccessibilityIds()
        setupRxBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRefreshControlBounds()
        setupInfoBubbleConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setBars(hidden: false)
    }

    
    // MARK:- Setup Views

    private func addCollectionView() {
        view.addSubviewForAutoLayout(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
            collectionView.topAnchor.constraint(equalTo: isSafeAreaAvailable ? safeTopAnchor : view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func addInfoBubbleView() {
        view.addSubviewForAutoLayout(infoBubbleView)
        let bubbleTap = UITapGestureRecognizer(target: self, action: #selector(onBubbleTapped))
        infoBubbleView.addGestureRecognizer(bubbleTap)
    }
    
    private func setupCollectionView() {
        collectionView.registerFeedHeaders(viewModel.allHeaderPresenters)
        collectionView.registerFeedCells(viewModel.allCellItemPresenters)
        collectionView.register(CollectionViewFooter.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: CollectionViewFooter.reusableID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = waterFallLayout
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
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
    
    private func setupInfoBubbleConstraints() {
        infoBubbleTopConstraints?.isActive = false
        infoBubbleTopConstraints = infoBubbleView.topAnchor.constraint(equalTo: collectionView.topAnchor,
                                                                       constant: waterFallLayout.yOffsetForTopItemInLastSection())
        infoBubbleTopConstraints?.isActive = true
        NSLayoutConstraint.activate([
            infoBubbleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoBubbleView.heightAnchor.constraint(equalToConstant: InfoBubbleView.bubbleHeight)
        ])
    }

    private func setupNavBar() {
        setNavBarTitleStyle(.custom(navbarSearch))
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
    
    private func setupRxBindings() {
        viewModel.infoBubbleText.asObservable()
            .bind { [weak self] _ in
                self?.infoBubbleView.invalidateIntrinsicContentSize()
            }.disposed(by: disposeBag)
        
        viewModel.infoBubbleText.asObservable()
            .bind(to: infoBubbleView.title.rx.text)
            .disposed(by: disposeBag)
        viewModel.infoBubbleVisible.asObservable()
            .map { !$0 }
            .bind(to: infoBubbleView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.sectionsDriver.drive(onNext: { [weak self] _ in
            self?.refreshFeedCollectionView()
        }).disposed(by: disposeBag)
    }
    
    private func setBars(hidden: Bool, animated: Bool = true) {
        tabBarController?.setTabBarHidden(hidden, animated: animated)
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
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


// MARK:- Scroll View Delegates

extension FeedViewController {
    
    /// Return true if user scrolls with finger moving downwards
    private func scrollViewIsScrollingDown(_ scrollView: UIScrollView) -> Bool {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        return translation.y > 0
    }
    
    private var allHeadersAreHidden: Bool {
        return collectionView.contentOffset.y > waterFallLayout.lastHeaderBottomY()
    }
    
    private var infoBubbleTopConstant: CGFloat {
        let minYOffset = waterFallLayout.minYOffsetForTopItemInLastSection()
        let currentOffset = waterFallLayout.yOffsetForTopItemInLastSection() - collectionView.contentOffset.y
        return currentOffset >= minYOffset ? currentOffset : minYOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if allHeadersAreHidden {
            setBars(hidden: !scrollViewIsScrollingDown(scrollView))
        } else if collectionView.contentOffset.y == 0 {
            setBars(hidden: false)
        }
        infoBubbleTopConstraints?.constant = infoBubbleTopConstant
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let feedPresenter = viewModel.item(for: indexPath),
            let cell = collectionView.dequeueReusableCell(withFeedPresenter: feedPresenter,
                                                          forIndexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            guard let headerViewModel = viewModel.header(for: indexPath.section),
                let headerCell = collectionView.dequeueReusableHeaderView(withFeedPresenter: headerViewModel,
                                                                          for: indexPath) else {
                return UICollectionReusableView()
            }
        
            FeedCellDrawer.configure(withHeaderView: headerCell, for: headerViewModel)
            return headerCell
        case UICollectionElementKindSectionFooter:
            guard let footer: CollectionViewFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                                     withReuseIdentifier: CollectionViewFooter.reusableID,
                                                                                                     for: indexPath) as? CollectionViewFooter else {
                return UICollectionReusableView()
            }
            collectionViewFooter = footer
            refreshFooter()
            return footer
        default:
            return UICollectionReusableView()
        }
    }
}

extension FeedViewController: WaterFallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 300) // FIXME: Until we have real cells
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForHeaderForSectionAt section: Int) -> CGFloat {
        return viewModel.header(for: section)?.height ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForFooterInSection section: Int) -> CGFloat {
        if section == viewModel.numberOfSections() - 1 {
            return SharedConstants.listingListFooterHeight
        }
        return 0
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
    
    @objc private func onBubbleTapped() {
        viewModel.bubbleTapped()
    }
    
    private func refreshFooter() {
        guard let footer = collectionViewFooter else { return }
        footer.status = .loading // FIXME: Add real logic for footer
    }
    
    private func refreshFeedCollectionView() {
        // FIXME: Add insert/delete/reloadSection logic
        collectionView.reloadData()
    }
}

