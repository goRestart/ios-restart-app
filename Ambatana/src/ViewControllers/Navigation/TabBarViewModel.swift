import LGCoreKit
import RxSwift
import LGComponents

class TabBarViewModel: BaseViewModel {
    weak var navigator: AppNavigator?

    static let engagementBadgingIndicatorValue = "·"
    
    var notificationsBadge = Variable<String?>(nil)
    var chatsBadge = Variable<String?>(nil)
    var sellBadge = Variable<String?>(nil)
    var homeBadge = Variable<String?>(nil)
    
    var shouldShowRealEstateTooltip: Bool {
        return featureFlags.realEstateEnabled.isActive &&
            !keyValueStorage[.realEstateTooltipSellButtonAlreadyShown]
    }
    var isMostSearchedItemsCameraBadgeEnabled: Bool {
        return featureFlags.mostSearchedDemandedItems == .cameraBadge
    }
    var shouldShowCameraBadge: Bool {
        return isMostSearchedItemsCameraBadgeEnabled && !keyValueStorage[.mostSearchedItemsCameraBadgeAlreadyShown]
    }
    var shouldShowHomeBadge: Bool {
        return featureFlags.engagementBadging.isActive
    }
    var userIsLoggedIn: Bool {
        return sessionManager.loggedIn
    }

    private let notificationsManager: NotificationsManager
    private let myUserRepository: MyUserRepository
    private let keyValueStorage: KeyValueStorage
    private let featureFlags: FeatureFlaggeable
    private let tracker: Tracker
    private let sessionManager: SessionManager
    
    private let disposeBag = DisposeBag()

    
    // MARK: - View lifecycle

    convenience override init() {
        self.init(notificationsManager: LGNotificationsManager.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(notificationsManager: NotificationsManager,
         myUserRepository: MyUserRepository,
         keyValueStorage: KeyValueStorage,
         featureFlags: FeatureFlaggeable,
         tracker: Tracker,
         sessionManager: SessionManager) {
        self.notificationsManager = notificationsManager
        self.myUserRepository = myUserRepository
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.tracker = tracker
        self.sessionManager = sessionManager
        super.init()
        setupRx()
    }


    // MARK: - Public methods

    func expandableButtonPressed(category: ExpandableCategory, source: PostingSource) {
        if category == .mostSearchedItems {
            navigator?.openMostSearchedItems(source: .mostSearchedTrendingExpandable, enableSearch: false)
        } else if let postCategory = category.listingCategory?.postingCategory(with: featureFlags) {
            trackSelectCategory(source: source, category: postCategory)
            navigator?.openSell(source: source, postCategory: postCategory, listingTitle: nil)
        }
    }
    
    func tagPressed(mostSearchedItem: LocalMostSearchedItem) {
        navigator?.openSell(source: .mostSearchedTagsExpandable,
                            postCategory: mostSearchedItem.category,
                            listingTitle: mostSearchedItem.name)
    }
    
    func realEstateTooltipText() -> NSMutableAttributedString {
        var newTextAttributes = [NSAttributedStringKey : Any]()
        newTextAttributes[.foregroundColor] = UIColor.primaryColor
        newTextAttributes[.font] = UIFont.systemSemiBoldFont(size: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        newTextAttributes[.paragraphStyle] = paragraphStyle
        
        let newText = NSAttributedString(string: R.Strings.commonNew, attributes: newTextAttributes)
        
        var titleTextAttributes = [NSAttributedStringKey : Any]()
        titleTextAttributes[.foregroundColor] = UIColor.white
        titleTextAttributes[.font] = UIFont.systemSemiBoldFont(size: 15)
        
        let title = featureFlags.realEstateNewCopy.isActive ? R.Strings.realEstateTooltipSellButtonTitle : R.Strings.realEstateTooltipSellButton
        let titleText = NSAttributedString(string: title, attributes: titleTextAttributes)
        
        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
        fullTitle.append(NSAttributedString(string: " "))
        fullTitle.append(titleText)
        
        return fullTitle
    }
    
    func tooltipDismissed() {
        guard shouldShowRealEstateTooltip else { return }
        keyValueStorage[.realEstateTooltipSellButtonAlreadyShown] = true
    }


    // MARK: - Private methods

    private func setupRx() {
        notificationsManager.unreadMessagesCount.asObservable()
            .map { $0.flatMap { $0 > 0 ? String($0) : nil } }
            .bind(to: chatsBadge)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(myUserRepository.rx_myUser,
            notificationsManager.unreadNotificationsCount.asObservable(),
            resultSelector: { (myUser, count) -> String? in
                guard myUser != nil else { return String(1) }
                return count.flatMap { $0 > 0 ? String($0) : nil }
            }).bind(to: notificationsBadge)
            .disposed(by: disposeBag)
        
        notificationsManager.newSellFeatureIndicator.asObservable()
            .bind(to: sellBadge)
            .disposed(by: disposeBag)
        
        notificationsManager.engagementBadgingNotifications.asObservable()
            .map { $0 ? TabBarViewModel.engagementBadgingIndicatorValue : nil }
            .bind(to: homeBadge)
            .disposed(by: disposeBag)
    }

    // MARK: - Trackings

    private func trackSelectCategory(source:PostingSource, category: PostCategory) {
        tracker.trackEvent(TrackerEvent.listingSellCategorySelect(typePage: source.typePage,
                                                                  postingType: EventParameterPostingType(category: category),
                                                                  category: category.listingCategory))
    }
}
