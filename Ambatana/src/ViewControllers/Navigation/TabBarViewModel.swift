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
    var userAvatar = Variable<UIImage?>(nil)
    
    var shouldShowRealEstateTooltip: Bool {
        return featureFlags.realEstateEnabled.isActive &&
            !keyValueStorage[.realEstateTooltipSellButtonAlreadyShown]
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

    func expandableButtonPressed(listingCategory: ListingCategory, source: PostingSource) {
        let postCategory = listingCategory.postingCategory(with: featureFlags)
        trackSelectCategory(source: source, category: postCategory)
        navigator?.openSell(source: source, postCategory: postCategory, listingTitle: nil)
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
        
        let titleText = NSAttributedString(string: R.Strings.realEstateTooltipSellButton,
                                           attributes: titleTextAttributes)
        
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

        notificationsManager.engagementBadgingNotifications.asObservable()
            .map { $0 ? TabBarViewModel.engagementBadgingIndicatorValue : nil }
            .bind(to: homeBadge)
            .disposed(by: disposeBag)

        myUserRepository
            .rx_myUser
            .distinctUntilChanged { $0?.objectId == $1?.objectId }
            .subscribe(onNext: { [weak self] myUser in
                self?.loadAvatar(for: myUser)
            })
            .disposed(by: disposeBag)
    }

    private func loadAvatar(for user: User?) {
        guard featureFlags.advancedReputationSystem11.isActive else { return }

        guard let avatarUrl = user?.avatar?.fileURL else {
            return self.userAvatar.value = nil
        }

        if let cachedImage = ImageDownloader.sharedInstance.cachedImageForUrl(avatarUrl) {
            return self.userAvatar.value = cachedImage
        }

        ImageDownloader
            .sharedInstance
            .downloadImageWithURL(avatarUrl) { [weak self] (result, _) in
                guard case .success((let image, _)) = result else { return }
                self?.userAvatar.value = image
        }
    }

    // MARK: - Trackings

    private func trackSelectCategory(source:PostingSource, category: PostCategory) {
        tracker.trackEvent(TrackerEvent.listingSellCategorySelect(typePage: source.typePage,
                                                                  postingType: EventParameterPostingType(category: category),
                                                                  category: category.listingCategory))
    }
}
