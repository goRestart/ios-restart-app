import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents

enum UserSource {
    case tabBar
    case listingDetail
    case chat
    case notifications
    case link
    case mainListing
}

struct UserViewHeaderAccounts {
    let facebookLinked: Bool
    let facebookVerified: Bool
    let googleLinked: Bool
    let googleVerified: Bool
    let emailLinked: Bool
    let emailVerified: Bool
}

protocol UserProfileViewModelDelegate: BaseViewModelDelegate {
    func vmShowNativeShare(_ socialMessage: SocialMessage)
}

final class UserProfileViewModel: BaseViewModel {

    // MARK: - Input
    let selectedTab = Variable<UserProfileTabType>(.selling)

    var navigator: PublicProfileNavigator?
    weak var profileNavigator: ProfileTabNavigator? {
        didSet {
            navigator = profileNavigator
            ratingListViewModel.tabNavigator = profileNavigator
        }
    }

    // MARK: - Output

    // Flag to define if the profile is accessed as My Profile (from tabbar)
    let isPrivateProfile: Bool

    // Flag to define if the user presented in the profile is 'my' user
    let isMyUser = Variable<Bool>(false)
    
    var myUserId: String? {
        return myUserRepository.myUser?.objectId
    }
    var myUserName: String? {
        return myUserRepository.myUser?.name
    }

    // Flag to define if there is a logged in user that allows special actions
    var isLoggedInUser: Bool { return sessionManager.loggedIn }

    var shouldShowCloseButtonInNavBar: Bool { return source == .mainListing }

    let arePushNotificationsEnabled = Variable<Bool?>(nil)
    var shouldShowPushPermissionsBanner: Bool {
        guard let areEnabled = arePushNotificationsEnabled.value else { return false }
        return !areEnabled && isPrivateProfile
    }
    
    var showClickToTalkBanner: Bool {
        return isLoggedInUser && featureFlags.clickToTalk.isActive && !keyValueStorage[.clickToTalkShown] && isPrivateProfile
    }
    
    var bannerHeight: CGFloat {
        if shouldShowPushPermissionsBanner { return PushPermissionsHeader.viewHeight }
        if showClickToTalkBanner { return LGTapToActionView.viewHeight }
        return 0
    }

    var shouldShowKarmaView: Bool { return isPrivateProfile }
    var shouldShowRatingCount: Bool { return self.featureFlags.advancedReputationSystem11.isActive }
    var isTapOnRatingStarsEnabled: Bool { return self.featureFlags.advancedReputationSystem11.isActive }

    var userName: Driver<String?> { return user.asDriver().map {$0?.name} }
    var userAvatarURL: Driver<URL?> { return user.asDriver().map {$0?.avatar?.fileURL} }
    var userIsDummy: Driver<Bool> { return user.asDriver().map {$0?.type == .dummy && self.featureFlags.dummyUsersInfoProfile.isActive } }
    var userLocation: Driver<String?> { return user.asDriver().map{$0?.postalAddress.cityStateString} }
    var userAccounts: Driver<UserViewHeaderAccounts?> { return user.asDriver().map { [weak self] in self?.buildAccountsModel($0) } }
    var userRatingAverage: Driver<Float> { return user.asDriver().map{$0?.ratingAverage ?? 0} }
    var userRatingCount: Driver<Int> { return user.asDriver().map{$0?.ratingCount ?? 0} }
    var userIsProfessional: Driver<Bool> { return user.asDriver().map {$0?.type == .pro} }
    var userBio: Driver<String?> { return user.asDriver().map { $0?.biography } }
    var userScore: Driver<Int> { return user.asDriver().map { $0?.reputationPoints ?? 0} }
    var userMemberSinceText: Driver<String?> { return .just(nil) } // Not available in User Model yet
    var userAvatarPlaceholder: Driver<UIImage?> { return user.asDriver().map { $0?.makeAvatarPlaceholder(isPrivateProfile: self.isPrivateProfile) } }
    var userBadge: Driver<UserHeaderViewBadge> { return makeUserBadge() }
    let userRelationIsBlocked = Variable<Bool>(false)
    let userRelationIsBlockedBy = Variable<Bool>(false)
    var userRelationText: Driver<String?> { return makeUserRelationText() }
    var listingListViewModel: Driver<ListingListViewModel?> { return makeListingListViewModelDriver() }
    let ratingListViewModel: UserRatingListViewModel
    let showBubbleNotification = PublishSubject<BubbleNotificationData>()
    
    var chatNowButtonIsHidden: Driver<Bool> {
        return Observable.combineLatest(user.asObservable(), isMyUser.asObservable()) { user, isMyUser in
            guard let user = user else { return false }
            return user.isDummy || user.isProfessional || isMyUser || !self.featureFlags.openChatFromUserProfile.isActive
        }.asDriver(onErrorJustReturn: false)
    }
    
    weak var delegate: UserProfileViewModelDelegate?

    // MARK: - Private

    private let user: Variable<User?>

    private let sessionManager: SessionManager
    private let myUserRepository: MyUserRepository
    private let userRepository: UserRepository
    private let listingRepository: ListingRepository
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private let notificationsManager: NotificationsManager?
    private let interestedHandler: InterestedHandleable?
    private let bubbleNotificationManager: BubbleNotificationManager?

    private let disposeBag: DisposeBag
    private let source: UserSource

    private let sellingListingListRequester: UserListingListRequester
    private let soldListingListRequester: UserListingListRequester
    private let favoritesListingListRequester: UserListingListRequester

    private let sellingListingListViewModel: ListingListViewModel
    private let soldListingListViewModel: ListingListViewModel
    private let favoritesListingListViewModel: ListingListViewModel
    private let keyValueStorage: KeyValueStorage
    
    init (sessionManager: SessionManager,
          myUserRepository: MyUserRepository,
          userRepository: UserRepository,
          listingRepository: ListingRepository,
          tracker: Tracker,
          featureFlags: FeatureFlaggeable,
          notificationsManager: NotificationsManager?,
          interestedHandler: InterestedHandleable?,
          bubbleNotificationManager: BubbleNotificationManager?,
          user: User?,
          source: UserSource,
          isPrivateProfile: Bool,
          keyValueStorage: KeyValueStorage = KeyValueStorage.sharedInstance) {
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.listingRepository = listingRepository
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.notificationsManager = notificationsManager
        self.interestedHandler = interestedHandler
        self.bubbleNotificationManager = bubbleNotificationManager
        self.user = Variable<User?>(user)
        self.source = source
        self.isPrivateProfile = isPrivateProfile
        self.keyValueStorage = keyValueStorage
        let status = UserProfileViewModel.sellingListingStatusCode()
        self.sellingListingListRequester = UserStatusesListingListRequester(statuses: status,
                                                                            itemsPerPage: SharedConstants.numListingsPerPageDefault)
        self.soldListingListRequester = UserStatusesListingListRequester(statuses: { [.sold, .soldOld] },
                                                                         itemsPerPage: SharedConstants.numListingsPerPageDefault)
        self.favoritesListingListRequester = UserFavoritesListingListRequester()

        let sellingSource: ListingListViewModel.ListingListViewContainer = isPrivateProfile ? .privateProfileSelling : .publicProfileSelling
        let soldSource: ListingListViewModel.ListingListViewContainer = isPrivateProfile ? .privateProfileSold : .publicProfileSold
        self.sellingListingListViewModel = ListingListViewModel(requester: self.sellingListingListRequester,
                                                                isPrivateList: true,
                                                                source: sellingSource)
        self.soldListingListViewModel = ListingListViewModel(requester: self.soldListingListRequester,
                                                             isPrivateList: true,
                                                             source: soldSource)
        self.favoritesListingListViewModel = ListingListViewModel(requester: self.favoritesListingListRequester,
                                                                  isPrivateList: true,
                                                                  source: .publicProfileSelling)
        self.ratingListViewModel = UserRatingListViewModel(userId: user?.objectId ?? "", tabNavigator: nil)

        self.disposeBag = DisposeBag()
        super.init()

        self.sellingListingListViewModel.dataDelegate = self
        self.sellingListingListViewModel.listingCellDelegate = self
        self.soldListingListViewModel.dataDelegate = self
        self.favoritesListingListViewModel.dataDelegate = self

        setupRxBindings()

        if isPrivateProfile {
            subscribeForNotificationPermissions()
        }
    }

    static func makePublicProfile(user: User, source: UserSource) -> UserProfileViewModel {
        return UserProfileViewModel(sessionManager: Core.sessionManager,
                                    myUserRepository: Core.myUserRepository,
                                    userRepository: Core.userRepository,
                                    listingRepository: Core.listingRepository,
                                    tracker: TrackerProxy.sharedInstance,
                                    featureFlags: FeatureFlags.sharedInstance,
                                    notificationsManager: nil,
                                    interestedHandler: InterestedHandler(),
                                    bubbleNotificationManager:  LGBubbleNotificationManager.sharedInstance,
                                    user: user,
                                    source: source,
                                    isPrivateProfile: false)
    }

    static func makePublicProfile(chatInterlocutor: ChatInterlocutor, source: UserSource) -> UserProfileViewModel {
        let user = LocalUser(chatInterlocutor: chatInterlocutor)
        return makePublicProfile(user: user, source: source)
    }

    static func makePrivateProfile(source: UserSource) -> UserProfileViewModel {
        return UserProfileViewModel(sessionManager: Core.sessionManager,
                                    myUserRepository: Core.myUserRepository,
                                    userRepository: Core.userRepository,
                                    listingRepository: Core.listingRepository,
                                    tracker: TrackerProxy.sharedInstance,
                                    featureFlags: FeatureFlags.sharedInstance,
                                    notificationsManager: LGNotificationsManager.sharedInstance,
                                    interestedHandler: nil,
                                    bubbleNotificationManager: nil,
                                    user: nil,
                                    source: source,
                                    isPrivateProfile: true)
    }

    private static func sellingListingStatusCode() -> () -> [ListingStatusCode] {
        return { [.pending, .approved, .discarded] }
    }

    private func loadListingContent() {
        switch selectedTab.value {
        case .selling: sellingListingListViewModel.retrieveListings()
        case .sold: soldListingListViewModel.retrieveListings()
        case .favorites: favoritesListingListViewModel.retrieveListings()
        case .reviews: ratingListViewModel.userRatingListRequester.retrieveFirstPage()
        }
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        updateNotificationPermissionsValue()
        ratingListViewModel.didBecomeActive(firstTime)

        if isPrivateProfile && isMyUser.value {
            myUserRepository.refresh(nil)
        } else {
            retrieveUserData()
        }

        loadListingContent()
        trackVisit()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Public methods

extension UserProfileViewModel {

    func didTapCloseButton() {
        profileNavigator?.closeProfile()
    }
    
    func didTapKarmaScoreView() {
        guard isPrivateProfile else { return }
        profileNavigator?.openUserVerificationView()
        trackVerifyAccountStart()
    }

    func didTapAvatar() {
        guard let user = user.value, featureFlags.advancedReputationSystem11.isActive else { return }
        navigator?.openAvatarDetail(isPrivate: isPrivateProfile, user: user)
        trackOpenAvatarDetail()
    }

    func updateAvatar(with image: UIImage) {
        guard let imageData = image.dataForAvatar() else { return }
        myUserRepository.updateAvatar(imageData,
                                      progressBlock: nil,
                                      completion: { [weak self] result in
                                        if let _ = result.value {
                                            self?.trackUpdateAvatarComplete()
                                            self?.refreshUser()
                                        } else {
                                            self?.delegate?
                                                .vmShowAutoFadingMessage(R.Strings.settingsChangeProfilePictureErrorGeneric,
                                                                         completion: nil)
                                        }
        })
    }

    // The Reputation Points after an Avatar Update takes some time to be processed
    // We refresh the user a few times to make sure the points are up to date.
    private func refreshUser(retries: Int = 0) {
        guard retries < 3 else { return }
        myUserRepository.refresh { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self?.refreshUser(retries: retries + 1)
            })
        }
    }

    func didTapShareButton() {
        guard let socialMessage = makeSocialMessage() else { return }
        delegate?.vmShowNativeShare(socialMessage)
        trackShareStart()
    }

    func didTapSettingsButton() {
        guard isPrivateProfile else { return }
        profileNavigator?.openSettings()
    }

    func didTapBlockUserButton() {
        guard let userId = user.value?.objectId else { return }
        delegate?.vmShowLoading(R.Strings.commonLoading)
        userRepository.blockUserWithId(userId) { [weak self] result in
            self?.trackBlock(userId)

            var afterMessageCompletion: (() -> ())? = nil
            if let _ = result.value {
                self?.userRelationIsBlocked.value = true
            } else {
                afterMessageCompletion = {
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.blockUserErrorGeneric, completion: nil)
                }
            }
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: afterMessageCompletion)
        }
    }

    func didTapUnblockUserButton() {
        guard let userId = user.value?.objectId else { return }

        delegate?.vmShowLoading(R.Strings.commonLoading)
        userRepository.unblockUserWithId(userId) { [weak self] result in
            self?.trackUnblock(userId)

            var afterMessageCompletion: (() -> ())? = nil
            if let _ = result.value {
                self?.userRelationIsBlocked.value = false
            } else {
                afterMessageCompletion = {
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.unblockUserErrorGeneric, completion: nil)
                }
            }
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: afterMessageCompletion)
        }
    }

    func didTapReportUserButton() {
        guard let userReportedId = user.value?.objectId else { return }
        navigator?.openUserReport(source: .profile, userReportedId: userReportedId)
    }
    
    func makeSocialMessage() -> SocialMessage? {
        guard let user = user.value else { return nil }
        return UserSocialMessage(user: user,
                                 itsMe: isMyUser.value,
                                 myUserId: myUserId,
                                 myUserName: myUserName)
    }
}

// MARK: - Private Methods

extension UserProfileViewModel {

    private func makeListingListViewModelDriver() -> Driver<ListingListViewModel?> {
        return selectedTab
            .asDriver()
            .map { [weak self] tab in
                switch tab {
                case .selling: return self?.sellingListingListViewModel
                case .sold: return self?.soldListingListViewModel
                case .favorites: return self?.favoritesListingListViewModel
                case .reviews: return nil
                }
        }
    }

    private func makeUserRelationText() -> Driver<String?> {
        return Driver.combineLatest(userRelationIsBlocked.asDriver(),
                                    userRelationIsBlockedBy.asDriver(),
                                    userName) { (blocked, blockedBy, userName) -> String? in
                                        if blocked {
                                            if let userName = userName {
                                                return R.Strings.profileBlockedByMeLabelWName(userName)
                                            } else {
                                                return R.Strings.profileBlockedByMeLabel
                                            }
                                        } else if blockedBy {
                                            return R.Strings.profileBlockedByOtherLabel
                                        }
                                        return nil
        }
    }

    private func makeUserBadge() -> Driver<UserHeaderViewBadge> {
        return user.asDriver().map { [weak self] user in
            guard let strongSelf = self, let user = user else { return .noBadge }
            if strongSelf.featureFlags.showProTagUserProfile && user.isProfessional {
                return .pro
            } else {
                return UserHeaderViewBadge(userBadge: user.reputationBadge)
            }
        }
    }

    private func setupRxBindings() {
        if isPrivateProfile {
            setupMyUserRxBindings()
        } else {
            retrieveUserData()
        }
        setupTabRxBindings()
        setupListingsListRxBindings()
    }

    func retrieveUserData() {
        guard let userId = user.value?.objectId else { return }
        userRepository.show(userId) { [weak self] result in
            self?.user.value = result.value
            self?.isMyUser.value = result.value?.objectId == self?.myUserRepository.myUser?.objectId
        }
    }

    private func setupMyUserRxBindings() {
        myUserRepository
            .rx_myUser
            .ignoreWhen { [weak self] myUser in
                guard let `self` = self else { return true }
                // Only accept events when view is active or the user has changed
                return !self.active && self.user.value?.objectId == myUser?.objectId
            }
            .bind { [weak self] myUser in
                self?.user.value = myUser
                self?.isMyUser.value = true
            }
            .disposed(by: disposeBag)
    }

    private func setupTabRxBindings() {
        selectedTab
            .asObservable()
            .skip(1) // Skip default tab selection
            .subscribeNext { [weak self] _ in
                self?.loadListingContent()
            }
            .disposed(by: disposeBag)
    }

    private func setupListingsListRxBindings() {
        user
            .asObservable()
            .distinctUntilChanged { $0?.objectId == $1?.objectId }
            .subscribeNext { [weak self] user in
                guard let user = user else { return }
                self?.userDidChange(newUser: user)
            }
            .disposed(by: disposeBag)

        if isPrivateProfile {
            listingRepository
                .events
                .bind { [weak self] event in
                    self?.didChangeListings(by: event)
                }
                .disposed(by: disposeBag)
        }
    }

    private func didChangeListings(by event: ListingEvent) {
        switch event {
        case let .update(listing):
            sellingListingListViewModel.update(listing: listing)
        case .sold, .unSold:
            sellingListingListViewModel.refresh()
            soldListingListViewModel.refresh()
        case .favorite, .unFavorite:
            favoritesListingListViewModel.refresh()
        case let .create(listing):
            sellingListingListViewModel.prepend(listing: listing)
        case let .delete(listingId):
            sellingListingListViewModel.delete(listingId: listingId)
            soldListingListViewModel.delete(listingId: listingId)
        case let .createListings(listings):
            sellingListingListViewModel.prepend(listings: listings)
        }
    }

    private func userDidChange(newUser user: User) {
        updateListings(with: user)
        ratingListViewModel.didBecomeActive(false)
        retrieveUsersRelation()
    }

    private func updateListings(with user: User) {
        sellingListingListRequester.userObjectId = user.objectId
        soldListingListRequester.userObjectId = user.objectId
        favoritesListingListRequester.userObjectId = user.objectId
        ratingListViewModel.userRatingListRequester.userId = user.objectId ?? ""
        ratingListViewModel.userIdRated = user.objectId ?? ""
        
        sellingListingListViewModel.resetUI()
        soldListingListViewModel.resetUI()
        favoritesListingListViewModel.resetUI()
        loadListingContent()
    }

    private func buildAccountsModel(_ user: User?) -> UserViewHeaderAccounts {
        return UserViewHeaderAccounts(facebookLinked: user?.facebookAccount != nil,
                                      facebookVerified: user?.facebookAccount?.verified ?? false,
                                      googleLinked: user?.googleAccount != nil,
                                      googleVerified: user?.googleAccount?.verified ?? false,
                                      emailLinked: user?.emailAccount != nil,
                                      emailVerified: user?.emailAccount?.verified ?? false)
    }

    private func retrieveUsersRelation() {
        guard let userId = user.value?.objectId else { return }
        guard userId != myUserRepository.myUser?.objectId else { return }

        userRepository.retrieveUserToUserRelation(userId) { [weak self] result in
            guard let userRelation = result.value else { return }
            self?.userRelationIsBlocked.value = userRelation.isBlocked
            self?.userRelationIsBlockedBy.value = userRelation.isBlockedBy
        }
    }

    private func deleteListing(withId listingId: String) {
        delegate?.vmShowLoading(R.Strings.commonLoading)
        listingRepository.delete(listingId: listingId) { [weak self] result in
            let message: String? = result.error != nil ? R.Strings.productDeleteSendErrorGeneric : nil
            self?.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }
}

// MARK: - User Interactions

extension UserProfileViewModel {

    func didTapPushPermissionsBanner() {
        trackPushPermissionStart()

        let positiveClosure = { [weak self] in
            self?.trackPushPermissionComplete()
            LGPushPermissionsManager.sharedInstance.showPushPermissionsAlert(prePermissionType: .profile)
        }

        let negativeClosure: () -> () = { [weak self] in
            self?.trackPushPermissionCancel()
        }

        let positive = UIAction(interface: .styledText(R.Strings.profilePermissionsAlertOk, .standard),
                                action: positiveClosure,
                                accessibility: AccessibilityId.userPushPermissionOK)
        let negative = UIAction(interface: .styledText(R.Strings.profilePermissionsAlertCancel, .cancel),
                                action:negativeClosure,
                                accessibility: AccessibilityId.userPushPermissionCancel)

        delegate?.vmShowAlertWithTitle(R.Strings.profilePermissionsAlertTitle,
                                       text: R.Strings.profilePermissionsAlertMessage,
                                       alertType: .iconAlert(icon: R.Asset.IconsButtons.customPermissionProfile.image),
                                       actions: [negative, positive])
    }
    
    func didTapSmokeTestBanner(feature: LGSmokeTestFeature) {
        guard let user = user.value else { return }
        let userAvatarInfo = UserAvatarInfo(avatarURL: user.avatar?.fileURL,
                                            placeholder: user.makeAvatarPlaceholder(isPrivateProfile: isPrivateProfile))
        trackSmokeTestOpened(testType: feature.testType)
        profileNavigator?.openSmokeTest(feature: feature, userAvatarInfo: userAvatarInfo)
    }
}

// MARK: - ListingList Data Delegate

extension UserProfileViewModel: ListingListViewModelDataDelegate {
    func listingListVMDidSucceedRetrievingCache(viewModel: ListingListViewModel) {
        // No cache for profile for now
    }

    func listingListMV(_ viewModel: ListingListViewModel,
                       didFailRetrievingListingsPage page: UInt,
                       hasListings: Bool,
                       error: RepositoryError) {
        guard !hasListings && page == 0,
            let errorState = makeErrorState(for: viewModel, with: error) else { return }
        viewModel.setErrorState(errorState)
    }

    func listingListVM(_ viewModel: ListingListViewModel,
                       didSucceedRetrievingListingsPage page: UInt,
                       withResultsCount resultsCount: Int,
                       hasListings: Bool,
                       containsRecentListings: Bool) {
        guard !hasListings && page == 0,
            let emptyState = makeEmptyState(for: viewModel) else { return }
        viewModel.setEmptyState(emptyState)
    }

    func listingListVM(_ viewModel: ListingListViewModel,
                       didSelectItemAtIndex index: Int,
                       thumbnailImage: UIImage?,
                       originFrame: CGRect?) {
        guard let listing = viewModel.listingAtIndex(index), !listing.status.isDiscarded else { return }
        guard let requester = viewModel.listingListRequester else { return }

        let cellModels = viewModel.objects
        let data = ListingDetailData.listingList(listing: listing, cellModels: cellModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        let source: EventParameterListingVisitSource = viewModel === favoritesListingListViewModel ? .favourite : .profile
        navigator?.openListing(data, source: source, actionOnFirstAppear: .nonexistent)
    }

    func vmProcessReceivedListingPage(_ Listings: [ListingCellModel], page: UInt) -> [ListingCellModel] { return Listings }
    func vmDidSelectSellBanner(_ type: String) {}
    func vmDidSelectCollection(_ type: CollectionCellType) {}
}

// MARK: Error & Empty States

extension UserProfileViewModel {
    private func makeErrorState(for viewModel: ListingListViewModel, with error: RepositoryError) -> LGEmptyViewModel? {
        let action: (() -> ())? = { [weak viewModel] in viewModel?.refresh() }
        guard let errorState = LGEmptyViewModel.map(from: error, action: action) else { return nil }
        return LGEmptyViewModel.Lenses.icon.set(nil, errorState)
    }

    private func makeEmptyState(for viewModel: ListingListViewModel)  -> LGEmptyViewModel? {
        let errTitle: String?
        let errButTitle: String?
        var errButAction: (() -> Void)? = nil
        let itsMe = isPrivateProfile || isMyUser.value

        switch viewModel {
        case let vm where vm === sellingListingListViewModel:
            errTitle = R.Strings.profileSellingNoProductsLabel
            errButTitle = itsMe ? nil : R.Strings.profileSellingOtherUserNoProductsButton
        case let vm where vm === soldListingListViewModel:
            errTitle = R.Strings.profileSoldNoProductsLabel
            errButTitle = itsMe ? nil : R.Strings.profileSoldOtherNoProductsButton
        case let vm where vm === favoritesListingListViewModel:
            errTitle = R.Strings.profileFavouritesMyUserNoProductsLabel
            errButTitle = itsMe ? nil : R.Strings.profileFavouritesMyUserNoProductsButton
            errButAction = { [weak self] in self?.profileNavigator?.openHome() }
        default:
            return nil
        }

        return LGEmptyViewModel(icon: nil,
                                title: errTitle,
                                body: nil,
                                buttonTitle: errButTitle,
                                action: errButAction,
                                secondaryButtonTitle: nil,
                                secondaryAction: nil,
                                emptyReason: .emptyResults,
                                errorCode: nil,
                                errorDescription: nil)
    }
}

// MARK: - SocialSharer Delegate

extension UserProfileViewModel: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {}

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        guard state == .completed else { return }
        trackShareComplete(shareType.trackingShareNetwork)
    }
}

// MARK: Push Permissions

extension UserProfileViewModel {
    private func subscribeForNotificationPermissions() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateNotificationPermissionsValue),
                                               name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue),
                                               object: nil)
    }

    @objc private func updateNotificationPermissionsValue() {
        arePushNotificationsEnabled.value = UIApplication.shared.areRemoteNotificationsEnabled
    }
}

// MARK: - Tracking

extension UserProfileViewModel {

    func trackVisit() {
        guard let user = user.value else { return }

        let typePage: EventParameterTypePage
        switch source {
        case .tabBar:
            typePage = .tabBar
        case .chat:
            typePage = .chat
        case .listingDetail:
            typePage = .listingDetail
        case .notifications:
            typePage = .notifications
        case .link:
            typePage = .external
        case .mainListing:
            typePage = .listingList
        }

        let eventTab: EventParameterTab
        switch selectedTab.value {
        case .selling:
            eventTab = .selling
        case .sold:
            eventTab = .sold
        case .favorites:
            eventTab = .favorites
        case .reviews:
            eventTab = .reviews
        }

        let profileType: EventParameterProfileType = isMyUser.value ? .privateParameter : .publicParameter

        let event = TrackerEvent.profileVisit(user, profileType: profileType, typePage: typePage, tab: eventTab)
        tracker.trackEvent(event)
    }

    func trackBlock(_ userId: String) {
        let event = TrackerEvent.profileBlock(.profile, blockedUsersIds: [userId], buttonPosition: .others)
        tracker.trackEvent(event)
    }

    func trackUnblock(_ userId: String) {
        let event = TrackerEvent.profileUnblock(.profile, unblockedUsersIds: [userId])
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func trackPushPermissionStart() {
        let goToSettings: EventParameterBoolean =
            LGPushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertStart(.push, typePage: .profile, alertType: .custom,
                                                             permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    func trackPushPermissionComplete() {
        let goToSettings: EventParameterBoolean =
            LGPushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertComplete(.push, typePage: .profile, alertType: .custom,
                                                                permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    func trackPushPermissionCancel() {
        let goToSettings: EventParameterBoolean =
            LGPushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertCancel(.push, typePage: .profile, alertType: .custom,
                                                              permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    func trackShareStart() {
        let profileType: EventParameterProfileType = isMyUser.value ? .privateParameter : .publicParameter
        let trackerEvent = TrackerEvent.profileShareStart(profileType)
        tracker.trackEvent(trackerEvent)
    }

    func trackShareComplete(_ shareNetwork: EventParameterShareNetwork) {
        let profileType: EventParameterProfileType = isMyUser.value ? .privateParameter : .publicParameter
        let trackerEvent = TrackerEvent.profileShareComplete(profileType, shareNetwork: shareNetwork)
        tracker.trackEvent(trackerEvent)
    }

    func trackUpdateAvatarComplete() {
        let trackerEvent = TrackerEvent.profileEditEditPicture()
        tracker.trackEvent(trackerEvent)
    }

    func trackVerifyAccountStart() {
        let event = TrackerEvent.verifyAccountStart(.profile)
        tracker.trackEvent(event)
    }

    func trackOpenAvatarDetail() {
        let event = TrackerEvent.profileOpenPictureDetail()
        tracker.trackEvent(event)
    }
    
    func trackSmokeTestOpened(testType: EventParameterSmokeTestType) {
        let event = TrackerEvent.smokeTestCtaTapped(testType: testType, source: .profile)
        tracker.trackEvent(event)
    }
    
    func trackSmokeTestShown(testType: EventParameterSmokeTestType) {
        let event = TrackerEvent.smokeTestCtaShown(testType: testType, source: .profile)
        tracker.trackEvent(event)
    }
}

extension UserProfileViewModel: ListingCellDelegate {
    func interestedActionFor(_ listing: Listing, userListing: LocalUser?, completion: @escaping (InterestedState) -> Void) {
        guard let interestedHandler = interestedHandler else { return }
        let interestedAction: () -> () = { [weak self] in
            interestedHandler.interestedActionFor(listing,
                                                  userListing: userListing,
                                                  stateCompletion: completion) { [weak self] interestedAction in
                switch interestedAction {
                case .openChatProUser:
                    guard let interlocutor = userListing else { return }
                    self?.navigator?.openListingChat(listing,
                                                     source: .profile,
                                                     interlocutor: interlocutor,
                                                     openChatAutomaticMessage: nil)
                case .askPhoneProUser:
                    guard let interlocutor = userListing else { return }
                    self?.navigator?.openAskPhoneFor(listing: listing, interlocutor: interlocutor)
                case .openChatNonProUser:
                    let chatDetailData = ChatDetailData.listingAPI(listing: listing)
                    self?.navigator?.openListingChat(data: chatDetailData,
                                                     source: .profile,
                                                     predefinedMessage: nil)
                case .triggerInterestedAction:
                    let (cancellable, timer) = LGTimer.cancellableWait(InterestedHandler.undoTimeout)
                    self?.notifyUndoBubble(withMessage: R.Strings.productInterestedBubbleMessage,
                                         duration: InterestedHandler.undoTimeout) {
                                            cancellable.cancel()
                    }
                    interestedHandler.handleCancellableInterestedAction(listing, timer: timer,  completion: completion)
                }
            }
        }
        
        if isLoggedInUser {
            interestedAction()
        } else {
            navigator?.openLogin(infoMessage: R.Strings.chatLoginPopupText,
                                 then: interestedAction)
        }
    }
    
    private func notifyUndoBubble(withMessage message: String,
                                duration: TimeInterval,
                                then action: @escaping () -> ()) {
        let action = UIAction(interface: .button(R.Strings.productInterestedUndo, .terciary) , action: action)
        let data = BubbleNotificationData(text: message,
                                          action: action)
        showBubbleNotification.onNext(data)
    }
    
    func showUndoBubble(inView view: UIView,
                        data: BubbleNotificationData) {
        bubbleNotificationManager?.showBubble(data: data,
                                              duration: InterestedHandler.undoTimeout,
                                              view: view,
                                              alignment: .bottomFullScreenView,
                                              style: .light)
    }
    
    func openAskPhoneFor(_ listing: Listing, interlocutor: LocalUser) {}
    
    func getUserInfoFor(_ listing: Listing, completion: @escaping (User?) -> Void) {
        guard let userId = listing.user.objectId else {
            completion(nil)
            return
        }
        userRepository.show(userId) { result in
            completion(result.value)
        }
    }

    func chatButtonPressedFor(listing: Listing) {}
    
    func openChatNow() {
        guard let user = user.value else { return }
        let listing = Listing.makeFakeListing(with: user)
        let chatDetailData = ChatDetailData.listingAPI(listing: listing)
        
        switch featureFlags.openChatFromUserProfile {
        case .baseline, .control:
            break
        case .vatiant1NoQuickAnswers, .variant2WithOneTimeQuickAnswers:
            let event = TrackerEvent.profileChatNowButtonTapped(user: user)
            tracker.trackEvent(event)
            navigator?.openListingChat(data: chatDetailData,
                                             source: .profile,
                                             predefinedMessage: nil)
        }
    }

    func editPressedForDiscarded(listing: Listing) {
        profileNavigator?.editListing(listing, pageType: .profile)
    }

    func moreOptionsPressedForDiscarded(listing: Listing) {
        guard let listingId = listing.objectId else { return }
        let deleteTitle = R.Strings.discardedProductsDelete
        let delete = UIAction(interface: .text(deleteTitle), action: { [weak self] in
            let actionOk = UIAction(interface: UIActionInterface.text(R.Strings.commonYes), action: {
                self?.deleteListing(withId: listingId)
            })
            let actionCancel = UIAction(interface: UIActionInterface.text(R.Strings.commonNo), action: {})
            self?.delegate?.vmShowAlert(nil,
                                        message: R.Strings.discardedProductsDeleteConfirmation,
                                        actions: [actionCancel, actionOk])
        })
        delegate?.vmShowActionSheet(R.Strings.commonCancel, actions: [delete])
    }
    
    func postNowButtonPressed(_ view: UIView, category: PostCategory, source: PostingSource) {}
    func bumpUpPressedFor(listing: Listing) {
        guard let id = listing.objectId else { return }
        let data = ListingDetailData.id(listingId: id)
        let actionOnFirstAppear = ProductCarouselActionOnFirstAppear.triggerBumpUp(purchases: [],
                                                                                   maxCountdown: 0,
                                                                                   bumpUpType: nil,
                                                                                   triggerBumpUpSource: .profile,
                                                                                   typePage: .profile)
        navigator?.openListing(data, source: .profile, actionOnFirstAppear: actionOnFirstAppear)
    }
}
