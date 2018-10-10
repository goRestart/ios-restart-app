import RxSwift
import RxDataSources
import LGCoreKit
import LGComponents
import GoogleMobileAds

final class ChatConversationsListViewController: ChatBaseViewController, ScrollableToTop, ConversationCellDelegate {
    
    private let viewModel: ChatConversationsListViewModel
    private let contentView = ChatConversationsListView()

    private let featureFlags: FeatureFlaggeable
    
    struct Ads {
        static let position: Int = 5
        static let customAdWidth: CGFloat = 336
        static let customAdSize = GADAdSizeFromCGSize(CGSize(width: 336, height: 280))
    }
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.icMoreOptions.image, for: .normal)
        button.addTarget(self, action: #selector(navigationBarOptionsButtonPressed), for: .touchUpInside)
        button.set(accessibilityId: .chatConversationsListOptionsNavBarButton)
        return button
    }()
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(navigationBarFiltersButtonPressed), for: .touchUpInside)
        button.set(accessibilityId: .chatConversationsListFiltersNavBarButton)
        return button
    }()
    
    var bannerView: GADBannerView =  {
        let banner = DFPBannerView(adSize: kGADAdSizeBanner)
        var adSizes = [NSValue]()
        if UIScreen.main.bounds.size.width >= Ads.customAdWidth {
            adSizes.append(NSValueFromGADAdSize(Ads.customAdSize))
        }
        adSizes.append(NSValueFromGADAdSize(kGADAdSizeBanner))
        adSizes.append(NSValueFromGADAdSize(kGADAdSizeMediumRectangle))
        adSizes.append(NSValueFromGADAdSize(kGADAdSizeLargeBanner))
        banner.validAdSizes = adSizes
        
        return banner
    }()
    
    // MARK: Lifecycle
    
    convenience init(viewModel: ChatConversationsListViewModel) {
        self.init(viewModel: viewModel,
                  featureFlags: FeatureFlags.sharedInstance)
    }
    
    init(viewModel: ChatConversationsListViewModel,
         featureFlags: FeatureFlaggeable) {
        self.viewModel = viewModel
        self.featureFlags = featureFlags
        super.init(viewModel: viewModel, featureFlags: featureFlags)
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false
        hasTabBar = true
        showConnectionToastView = !featureFlags.showChatConnectionStatusBar.isActive
    }
    
    override func loadView() {
        view = UIView()
        view.addSubviewForAutoLayout(contentView)

        NSLayoutConstraint.activate([
            safeTopAnchor.constraint(equalTo: contentView.topAnchor),
            safeBottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupNavigationBarRx()
        setupViewStateRx()
        setupTableViewRx()
        if featureFlags.showChatConnectionStatusBar.isActive {
            setupStatusBarRx()
        }
        if viewModel.shouldShowAds() {
            setupAdsRx()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Navigation Bar
    
    private func setupNavigationBar(isEditing: Bool) {
        if isEditing {
            setLetGoRightButtonWith(barButtonSystemItem: .cancel,
                                    selector: #selector(navigationBarCancelButtonPressed),
                                    animated: true)
        } else {
            setNavigationBarRightButtons([filtersButton, optionsButton],
                                         animated: true)
        }
    }
    
    // MARK: UI
    
    private func setupContentView() {
        contentView.refreshControlBlock = { [weak self] in
            self?.viewModel.retrieveFirstPage(completion: { [weak self] in
                self?.contentView.endRefresh()
                if let viewModel = self?.viewModel, viewModel.shouldShowAds() {
                    self?.bannerView.load(DFPRequest())
                }
            })
        }
    }
    
    // MARK: Rx
    
    private func setupNavigationBarRx() {
        viewModel.rx_navigationBarTitle
            .asDriver()
            .drive(onNext: { [weak self] title in
                self?.setNavBarTitle(title)
            })
            .disposed(by: bag)
        
        viewModel.rx_navigationBarFilterButtonImage
            .asDriver()
            .drive(onNext: { [weak self] image in
                self?.filtersButton.setImage(image, for: .normal)
            })
            .disposed(by: bag)
        
        viewModel.rx_isEditing
            .asDriver()
            .distinctUntilChanged()
            .drive(onNext: { [weak self] isEditing in
                self?.setupNavigationBar(isEditing: isEditing)
                self?.contentView.switchEditMode(isEditing: isEditing)
            })
            .disposed(by: bag)
    }
    
    private func setupViewStateRx() {
        viewModel
            .viewState
            .drive(onNext: { [weak self] viewState in
                switch viewState {
                case .loading:
                    self?.contentView.showActivityIndicator()
                case .data:
                    self?.contentView.showTableView()
                case .empty(let emptyViewModel):
                    self?.contentView.showEmptyView(with: emptyViewModel)
                case .error(let errorViewModel):
                    self?.contentView.showEmptyView(with: errorViewModel)
                }
            })
            .disposed(by: bag)
    }
    
    private static func dataSource(withCellDelegate delegate: ConversationCellDelegate) -> RxTableViewSectionedAnimatedDataSource<ChatConversationsListSectionModel> {
        let configureCell = { (
            dataSource: TableViewSectionedDataSource<ChatConversationsListSectionModel>,
            tableView: UITableView,
            indexPath: IndexPath,
            item: ChatConversationsListSectionModel.Item) -> UITableViewCell in
            switch dataSource[indexPath] {

            case .conversationCellData(let conversationCellData):
                if conversationCellData.isFakeListing {
                    guard let cell = tableView.dequeue(type: ChatAssistantConversationCell.self, for: indexPath) else {
                        return UITableViewCell()
                    }
                    cell.setupCellWith(data: conversationCellData, indexPath: indexPath)
                    return cell
                }
                if let userType = conversationCellData.userType,
                    userType == .dummy,
                    conversationCellData.listingId == nil {
                    guard let cell = tableView.dequeue(type: ChatAssistantConversationCell.self, for: indexPath) else {
                        return UITableViewCell()
                    }
                    cell.setupCellWith(data: conversationCellData, indexPath: indexPath)
                    return cell
                } else {
                    guard let cell = tableView.dequeue(type: ChatUserConversationCell.self, for: indexPath) else {
                        return UITableViewCell()
                    }
                    cell.setupCellWith(data: conversationCellData, indexPath: indexPath)
                    cell.delegate = delegate
                    return cell
                }
                
            case .adCellData( let adCellData):
                guard let cell = tableView.dequeue(type: ConversationAdCell.self, for: indexPath) else {
                    return UITableViewCell()
                }
                cell.setupWith(dfpData: adCellData)
                return cell
            }
        }
        
        let canEditRowAtIndexPath = { (dataSource: TableViewSectionedDataSource<ChatConversationsListSectionModel>, indexPath: IndexPath) -> Bool in
            switch dataSource[indexPath] {
            case .conversationCellData:
                return true
            case.adCellData:
                return false
            }
        }
        
        return RxTableViewSectionedAnimatedDataSource<ChatConversationsListSectionModel>(
            configureCell: configureCell,
            canEditRowAtIndexPath: canEditRowAtIndexPath
        )
    }
    
    private func setupTableViewRx() {
        let dataSource = ChatConversationsListViewController.dataSource(withCellDelegate: self)
        dataSource.decideViewTransition = { (_, _, changeSet) in
            return RxDataSources.ViewTransition.reload
        }

        viewModel.rx_conversations
            .asObservable()
            .map { [ChatConversationsListSectionModel(conversations: $0, header: "conversations")] }
            .bind(to: contentView.rx_tableView.items(dataSource: dataSource))
            .disposed(by: bag)
        
        contentView.rx_tableView
            .itemSelected
            .bind { [weak self] indexPath in
                self?.viewModel.tableViewDidSelectItem(at: indexPath)
            }
            .disposed(by: bag)
        
        contentView.rx_tableView
            .itemDeleted
            .bind { [weak self] indexPath in
                self?.viewModel.tableViewDidDeleteItem(at: indexPath)
            }
            .disposed(by: bag)

        contentView.rx_tableView
            .willDisplayCell // This is calling more cells than the visible ones!
            .asObservable()
            .bind { [weak self] (cell, index) in
                self?.viewModel.setCurrentIndex(index.row)
            }
            .disposed(by: bag)

    }

    private func setupStatusBarRx() {
        viewModel.rx_connectionBarStatus
            .asDriver()
            .drive(contentView.connectionBarStatus)
            .disposed(by: bag)
    }

    private func setupAdsRx() {
        bannerView.adUnitID = featureFlags.multiAdRequestInChatSectionAdUnitId
        bannerView.adSizeDelegate = self
        bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.load(DFPRequest())
    }
    
    // MARK: Navigation Bar Actions
    
    @objc private func navigationBarOptionsButtonPressed() {
        viewModel.openOptionsActionSheet()
    }
    
    @objc private func navigationBarFiltersButtonPressed() {
        viewModel.openFiltersActionSheet()
    }
    
    @objc private func navigationBarCancelButtonPressed() {
        viewModel.switchEditMode(isEditing: false)
    }

    // MARK: - ScrollableToTop

    func scrollToTop() {
        contentView.scrollToTop()
    }
    
    private func selectedPositionFor(adSize: CGSize) -> Int {
        let tableHeight = contentView.bounds.size.height
        let minBannerHeight = adSize.height/2
        let position = Int(((tableHeight - minBannerHeight) / ChatConversationsListView.Layout.rowHeight).rounded())
        return min(position, Ads.position)
    }
    
    private func updateWithAd(bannerView: GADBannerView) {
        self.bannerView = bannerView
        let sizeAd = bannerView.adSize.size
        contentView.resetDataSource()
        let dataSource = ChatConversationsListViewController.dataSource(withCellDelegate: self)
        dataSource.decideViewTransition = { (_, _, changeSet) in
            return RxDataSources.ViewTransition.reload
        }
        guard let adUnitID = bannerView.adUnitID else { return }
        let selectedPosition = selectedPositionFor(adSize: sizeAd)
        let adData = ConversationAdCellData(adUnitId: adUnitID,
                                            bannerHeight: sizeAd.height,
                                            bannerView: bannerView,
                                            position: selectedPosition)
        viewModel.adData = adData
        viewModel.rx_conversations
            .asObservable()
            .map { [ChatConversationsListSectionModel(conversations: $0, header: "conversations", adData: adData)] }
            .bind(to: contentView.rx_tableView.items(dataSource: dataSource))
            .disposed(by: bag)
    }


    // MARK: ConversationCellDelegate

    func bumpUpPressedFor(listingId: String) {
        viewModel.bumpUpPressedFor(listingId: listingId)
    }
}

extension ChatConversationsListViewController: GADAdSizeDelegate {
    
    /// Called before the ad view changes to the new size.
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        logMessage(.info,
                   type: [.monetization],
                   message: "Make your app layout changes here, if necessary. New banner ad size will be \(size).")
        updateWithAd(bannerView: bannerView)
    }
    
}

extension ChatConversationsListViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        logMessage(.info, type: [.monetization], message: "bannerView received: \(bannerView)")
        updateWithAd(bannerView: bannerView)
        viewModel.adShown(bannerSize: bannerView.adSize.size)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        logMessage(.error, type: [.monetization], message: "Fail to receive bannerView: \(error)")
        let errorCode = GADErrorCode(rawValue: error.code) ?? .internalError
        viewModel.adError(bannerSize: bannerView.adSize.size, errorCode: errorCode)
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        viewModel.adTapped(willLeaveApp: true, bannerSize: bannerView.adSize.size)
    }
    
}
