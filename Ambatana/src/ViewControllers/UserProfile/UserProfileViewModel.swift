//
//  UserProfileViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import RxCocoa

protocol UserProfileViewModelDelegate: BaseViewModelDelegate {
    func vmShowNativeShare(_ socialMessage: SocialMessage)
}

final class UserProfileViewModel: BaseViewModel {

    // MARK: - Input
    let selectedTab = Variable<UserProfileTabType>(.selling)

    weak var navigator: TabNavigator?
    weak var profileNavigator: ProfileTabNavigator? {
        didSet {
            navigator = profileNavigator
            ratingListViewModel.tabNavigator = navigator
        }
    }

    // MARK: - Output

    // Flag to define if the profile is accessed as My Profile (from tabbar)
    let isPrivateProfile: Bool

    // Flag to define if the user presented in the profile is 'my' user
    let isMyUser = Variable<Bool>(false)

    // Flag to define if there is a logged in user that allows special actions
    var isLoggedInUser: Bool { return sessionManager.loggedIn }

    var isMostSearchedItemsAvailable: Bool { return featureFlags.mostSearchedDemandedItems.isActive }
    var showMostSearchedItemsBanner: Bool { return isMostSearchedItemsAvailable && selectedTab.value == .selling }

    let arePushNotificationsEnabled = Variable<Bool?>(nil)
    var showPushPermissionsBanner: Bool {
        guard let areEnabled = arePushNotificationsEnabled.value else { return false }
        return !areEnabled && isPrivateProfile
    }

    var showKarmaView: Bool {
        return featureFlags.showAdvancedReputationSystem.isActive && isPrivateProfile
    }

    var userName: Driver<String?> { return user.asDriver().map {$0?.name} }
    var userAvatarURL: Driver<URL?> { return user.asDriver().map {$0?.avatar?.fileURL} }
    var userIsDummy: Driver<Bool> { return user.asDriver().map {$0?.type == .dummy && self.featureFlags.dummyUsersInfoProfile.isActive } }
    var userLocation: Driver<String?> { return user.asDriver().map{$0?.postalAddress.cityStateString} }
    var userAccounts: Driver<UserViewHeaderAccounts?> { return user.asDriver().map { [weak self] in self?.buildAccountsModel($0) } }
    var userRatingAverage: Driver<Float> { return user.asDriver().map{$0?.ratingAverage ?? 0} }
    var userIsProfessional: Driver<Bool> { return user.asDriver().map {$0?.type == .pro} }
    var userBio: Driver<String?> { return user.asDriver().map { $0?.biography } }
    var userMemberSinceText: Driver<String?> { return .just(nil) } // Not available in User Model yet
    var userAvatarPlaceholder: Driver<UIImage?> { return makeUserAvatar() }
    let userRelationIsBlocked = Variable<Bool>(false)
    let userRelationIsBlockedBy = Variable<Bool>(false)
    var userRelationText: Driver<String?> { return makeUserRelationText() }
    var listingListViewModel: Driver<ListingListViewModel?> { return makeListingListViewModelDriver() }
    let ratingListViewModel: UserRatingListViewModel

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

    private let disposeBag: DisposeBag
    private let source: UserSource

    private let sellingListingListRequester: UserListingListRequester
    private let soldListingListRequester: UserListingListRequester
    private let favoritesListingListRequester: UserListingListRequester

    private let sellingListingListViewModel: ListingListViewModel
    private let soldListingListViewModel: ListingListViewModel
    private let favoritesListingListViewModel: ListingListViewModel

    init (sessionManager: SessionManager,
          myUserRepository: MyUserRepository,
          userRepository: UserRepository,
          listingRepository: ListingRepository,
          tracker: Tracker,
          featureFlags: FeatureFlaggeable,
          notificationsManager: NotificationsManager?,
          user: User?,
          source: UserSource,
          isPrivateProfile: Bool) {
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.listingRepository = listingRepository
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.notificationsManager = notificationsManager
        self.user = Variable<User?>(user)
        self.source = source
        self.isPrivateProfile = isPrivateProfile

        let status = UserProfileViewModel.sellingListingStatusCode(with: featureFlags)
        self.sellingListingListRequester = UserStatusesListingListRequester(statuses: status,
                                                                            itemsPerPage: Constants.numListingsPerPageDefault)
        self.soldListingListRequester = UserStatusesListingListRequester(statuses: { [.sold, .soldOld] },
                                                                         itemsPerPage: Constants.numListingsPerPageDefault)
        self.favoritesListingListRequester = UserFavoritesListingListRequester()

        self.sellingListingListViewModel = ListingListViewModel(requester: self.sellingListingListRequester)
        self.soldListingListViewModel = ListingListViewModel(requester: self.soldListingListRequester)
        self.favoritesListingListViewModel = ListingListViewModel(requester: self.favoritesListingListRequester)
        self.ratingListViewModel = UserRatingListViewModel(userId: user?.objectId ?? "", tabNavigator: nil)

        self.disposeBag = DisposeBag()
        super.init()

        self.sellingListingListViewModel.dataDelegate = self
        self.sellingListingListViewModel.listingCellDelegate = self
        self.soldListingListViewModel.dataDelegate = self
        self.favoritesListingListViewModel.dataDelegate = self

        self.sellingListingListViewModel.retrieveListings()
        self.soldListingListViewModel.retrieveListings()
        self.favoritesListingListViewModel.retrieveListings()

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
                                    user: nil,
                                    source: source,
                                    isPrivateProfile: true)
    }

    private static func sellingListingStatusCode(with flags: FeatureFlaggeable) -> () -> [ListingStatusCode] {
        return { flags.discardedProducts.isActive ? [.pending, .approved, .discarded] : [.pending, .approved] }
    }

    private func loadListingContent() {
        switch selectedTab.value {
        case .selling: sellingListingListViewModel.retrieveListings()
        case .sold: soldListingListViewModel.retrieveListings()
        case .favorites: favoritesListingListViewModel.retrieveListings()
        case .reviews: break
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
    
    func didTapKarmaScoreView() {
        guard isPrivateProfile else { return }
        profileNavigator?.openVerificationView()
    }

    func didTapBuildTrustButton() {
        guard isPrivateProfile else { return }
        let userAccounts = buildAccountsModel(user.value)
        var verifyTypes: [VerificationType] = []
        if !userAccounts.emailVerified {
            verifyTypes.append(.email(myUserRepository.myUser?.email))
        }
        if !userAccounts.facebookVerified {
            verifyTypes.append(.facebook)
        }
        if !userAccounts.googleVerified {
            verifyTypes.append(.google)
        }
        guard !verifyTypes.isEmpty else { return }
        navigator?.openVerifyAccounts(verifyTypes,
                                      source: .profile(title: LGLocalizedString.chatConnectAccountsTitle,
                                                       description: LGLocalizedString.profileConnectAccountsMessage),
                                      completionBlock: nil)
    }

    func updateAvatar(with image: UIImage) {
        guard let imageData = image.dataForAvatar() else { return }
        myUserRepository.updateAvatar(imageData,
                                      progressBlock: nil,
                                      completion: { [weak self] result in
                                        if let _ = result.value {
                                            self?.trackUpdateAvatarComplete()
                                        } else {
                                            self?.delegate?
                                                .vmShowAutoFadingMessage(LGLocalizedString.settingsChangeProfilePictureErrorGeneric,
                                                                         completion: nil)
                                        }
        })
    }

    func didTapShareButton() {
        guard let user = user.value else { return }
        let myUserId = myUserRepository.myUser?.objectId
        let myUserName = myUserRepository.myUser?.name
        let socialMessage = UserSocialMessage(user: user,
                                              itsMe: isMyUser.value,
                                              myUserId: myUserId,
                                              myUserName: myUserName)
        delegate?.vmShowNativeShare(socialMessage)
        trackShareStart()
    }

    func didTapSettingsButton() {
        guard isPrivateProfile else { return }
        profileNavigator?.openSettings()
    }

    func didTapEditBioButton() {
        guard isPrivateProfile else { return }
        profileNavigator?.openEditUserBio()
    }

    func didTapBlockUserButton() {
        guard let userId = user.value?.objectId else { return }
        delegate?.vmShowLoading(LGLocalizedString.commonLoading)
        userRepository.blockUserWithId(userId) { [weak self] result in
            self?.trackBlock(userId)

            var afterMessageCompletion: (() -> ())? = nil
            if let _ = result.value {
                self?.userRelationIsBlocked.value = true
            } else {
                afterMessageCompletion = {
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.blockUserErrorGeneric, completion: nil)
                }
            }
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: afterMessageCompletion)
        }
    }

    func didTapUnblockUserButton() {
        guard let userId = user.value?.objectId else { return }

        delegate?.vmShowLoading(LGLocalizedString.commonLoading)
        userRepository.unblockUserWithId(userId) { [weak self] result in
            self?.trackUnblock(userId)

            var afterMessageCompletion: (() -> ())? = nil
            if let _ = result.value {
                self?.userRelationIsBlocked.value = false
            } else {
                afterMessageCompletion = {
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.unblockUserErrorGeneric, completion: nil)
                }
            }
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: afterMessageCompletion)
        }
    }

    func didTapReportUserButton() {
        guard let userReportedId = user.value?.objectId else { return }
        navigator?.openUserReport(source: .profile, userReportedId: userReportedId)
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
                                                return LGLocalizedString.profileBlockedByMeLabelWName(userName)
                                            } else {
                                                return LGLocalizedString.profileBlockedByMeLabel
                                            }
                                        } else if blockedBy {
                                            return LGLocalizedString.profileBlockedByOtherLabel
                                        }
                                        return nil
        }
    }

    private func makeUserAvatar() -> Driver<UIImage?> {
        if isPrivateProfile {
            return user.asDriver().map { LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor, name: $0?.name) }
        } else {
            return user.asDriver().map { LetgoAvatar.avatarWithID($0?.objectId, name: $0?.name) }
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
        delegate?.vmShowLoading(LGLocalizedString.commonLoading)
        listingRepository.delete(listingId: listingId) { [weak self] result in
            let message: String? = result.error != nil ? LGLocalizedString.productDeleteSendErrorGeneric : nil
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

        let positive = UIAction(interface: .styledText(LGLocalizedString.profilePermissionsAlertOk, .standard),
                                action: positiveClosure,
                                accessibilityId: .userPushPermissionOK)
        let negative = UIAction(interface: .styledText(LGLocalizedString.profilePermissionsAlertCancel, .cancel),
                                action:negativeClosure,
                                accessibilityId: .userPushPermissionCancel)

        delegate?.vmShowAlertWithTitle(LGLocalizedString.profilePermissionsAlertTitle,
                                       text: LGLocalizedString.profilePermissionsAlertMessage,
                                       alertType: .iconAlert(icon: UIImage(named: "custom_permission_profile")),
                                       actions: [negative, positive])
    }

    func didTapMostSearchedItems() {
        navigator?.openMostSearchedItems(source: .mostSearchedUserProfile, enableSearch: false)
    }
}

// MARK: - ListingList Data Delegate

extension UserProfileViewModel: ListingListViewModelDataDelegate {
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
                       hasListings: Bool) {
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
    func vmDidSelectMostSearchedItems() {}
}

// MARK: Error & Empty States

extension UserProfileViewModel {
    private func makeErrorState(for viewModel: ListingListViewModel, with error: RepositoryError) -> LGEmptyViewModel? {
        let action: (() -> ())? = { [weak viewModel] in viewModel?.refresh() }
        var errorState = LGEmptyViewModel.map(from: error, action: action)
        errorState?.icon = nil
        return errorState
    }

    private func makeEmptyState(for viewModel: ListingListViewModel)  -> LGEmptyViewModel? {
        let errTitle: String?
        let errButTitle: String?
        var errButAction: (() -> Void)? = nil
        let itsMe = isPrivateProfile || isMyUser.value

        switch viewModel {
        case let vm where vm === sellingListingListViewModel:
            errTitle = LGLocalizedString.profileSellingNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileSellingOtherUserNoProductsButton
        case let vm where vm === soldListingListViewModel:
            errTitle = LGLocalizedString.profileSoldNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileSoldOtherNoProductsButton
        case let vm where vm === favoritesListingListViewModel:
            errTitle = LGLocalizedString.profileFavouritesMyUserNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileFavouritesMyUserNoProductsButton
            errButAction = { [weak self] in self?.navigator?.openHome() }
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
                                errorCode: nil)
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
}

extension UserProfileViewModel: ListingCellDelegate {

    func chatButtonPressedFor(listing: Listing) {}

    func editPressedForDiscarded(listing: Listing) {
        profileNavigator?.editListing(listing, pageType: .profile)
    }

    func moreOptionsPressedForDiscarded(listing: Listing) {
        guard let listingId = listing.objectId else { return }
        let deleteTitle = LGLocalizedString.discardedProductsDelete
        let delete = UIAction(interface: .text(deleteTitle), action: { [weak self] in
            let actionOk = UIAction(interface: UIActionInterface.text(LGLocalizedString.commonYes), action: {
                self?.deleteListing(withId: listingId)
            })
            let actionCancel = UIAction(interface: UIActionInterface.text(LGLocalizedString.commonNo), action: {})
            self?.delegate?.vmShowAlert(nil,
                                        message: LGLocalizedString.discardedProductsDeleteConfirmation,
                                        actions: [actionCancel, actionOk])
        })
        delegate?.vmShowActionSheet(LGLocalizedString.commonCancel, actions: [delete])
    }
}
