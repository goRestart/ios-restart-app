import LGCoreKit
import RxSwift
import LGComponents

class TabBarViewModel: BaseViewModel {
    weak var navigator: AppNavigator?

    var notificationsBadge = Variable<String?>(nil)
    var chatsBadge = Variable<String?>(nil)
    var sellBadge = Variable<String?>(nil)
    
    var shouldShowRealEstateTooltip: Bool {
        return featureFlags.realEstateEnabled.isActive &&
            !keyValueStorage[.realEstateTooltipSellButtonAlreadyShown]
    }

    private let notificationsManager: NotificationsManager
    private let myUserRepository: MyUserRepository
    private let keyValueStorage: KeyValueStorage
    private let featureFlags: FeatureFlaggeable
    
    private let disposeBag = DisposeBag()

    
    // MARK: - View lifecycle

    convenience override init() {
        self.init(notificationsManager: LGNotificationsManager.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(notificationsManager: NotificationsManager,
         myUserRepository: MyUserRepository,
         keyValueStorage: KeyValueStorage,
         featureFlags: FeatureFlaggeable) {
        self.notificationsManager = notificationsManager
        self.myUserRepository = myUserRepository
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        super.init()
        setupRx()
    }


    // MARK: - Public methods

    func sellButtonPressed() {
        navigator?.openSell(source: .sellButton, postCategory: nil, listingTitle: nil)
    }
    
    func expandableButtonPressed(listingCategory: ListingCategory) {
        let postCategory = listingCategory.postingCategory(with: featureFlags)
        navigator?.openSell(source: .sellButton, postCategory: postCategory, listingTitle: nil)
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
    }
}
