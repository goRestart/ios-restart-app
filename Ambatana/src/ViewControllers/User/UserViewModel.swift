//
//  UserViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

enum UserSource {
    case tabBar
    case productDetail
    case chat
    case notifications
    case link
}

protocol UserViewModelDelegate: BaseViewModelDelegate {
    func vmOpenReportUser(_ reportUserVM: ReportUsersViewModel)
    func vmShowUserActionSheet(_ cancelLabel: String, actions: [UIAction])
    func vmShowNativeShare(_ socialMessage: SocialMessage)
}

class UserViewModel: BaseViewModel {
    // Constants
    fileprivate static let userBgEffectAlphaMax: CGFloat = 0.9
    fileprivate static let userBgTintAlphaMax: CGFloat = 0.54
    
    // Repositories / Managers
    fileprivate let sessionManager: SessionManager
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let userRepository: UserRepository
    fileprivate let listingRepository: ListingRepository
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let notificationsManager: NotificationsManager
    
    // Data & VMs
    fileprivate let user: Variable<User?>
    fileprivate(set) var isMyProfile: Bool
    fileprivate let userRelationIsBlocked = Variable<Bool>(false)
    fileprivate let userRelationIsBlockedBy = Variable<Bool>(false)
    fileprivate let source: UserSource
    fileprivate var socialMessage: SocialMessage? = nil
    
    fileprivate let sellingProductListViewModel: ProductListViewModel
    fileprivate let sellingProductListRequester: UserProductListRequester
    fileprivate let soldProductListViewModel: ProductListViewModel
    fileprivate let soldProductListRequester: UserProductListRequester
    fileprivate let favoritesProductListViewModel: ProductListViewModel
    fileprivate let favoritesProductListRequester: UserProductListRequester
    
    // Input
    let tab = Variable<UserViewHeaderTab>(.selling)
    
    // Output
    let navBarButtons = Variable<[UIAction]>([])
    let backgroundColor = Variable<UIColor>(UIColor.clear)
    let headerMode = Variable<UserViewHeaderMode>(.myUser)
    let userAvatarPlaceholder = Variable<UIImage?>(nil)
    let userAvatarURL = Variable<URL?>(nil)
    let userRatingAverage = Variable<Float?>(nil)
    let userRatingCount = Variable<Int?>(nil)
    let userRelationText = Variable<String?>(nil)
    let userName = Variable<String?>(nil)
    let userLocation = Variable<String?>(nil)
    let userAccounts = Variable<UserViewHeaderAccounts?>(nil)
    let pushPermissionsDisabledWarning = Variable<Bool?>(nil)
    
    let productListViewModel: Variable<ProductListViewModel>
    
    weak var delegate: UserViewModelDelegate?
    weak var navigator: TabNavigator?
    weak var profileNavigator: ProfileTabNavigator? {
        didSet {
            navigator = profileNavigator
        }
    }
    
    // Rx
    let disposeBag: DisposeBag
    
    
    // MARK: - Lifecycle
    
    static func myUserUserViewModel(_ source: UserSource) -> UserViewModel {
        return UserViewModel(user: nil, source: source, isMyProfile: true)
    }

    convenience init(chatInterlocutor: ChatInterlocutor, source: UserSource) {
        let user = LocalUser(chatInterlocutor: chatInterlocutor)
        self.init(user: user, source: source)
    }

    convenience init(user: User, source: UserSource) {
        self.init(user: user, source: source, isMyProfile: false)
    }

    private convenience init(user: User?, source: UserSource, isMyProfile: Bool) {
        let sessionManager = Core.sessionManager
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let listingRepository = Core.listingRepository
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let notificationsManager = LGNotificationsManager.sharedInstance
        self.init(sessionManager: sessionManager, myUserRepository: myUserRepository, userRepository: userRepository,
                  listingRepository: listingRepository, tracker: tracker, isMyProfile: isMyProfile, user: user, source: source,
                  featureFlags: featureFlags, notificationsManager: notificationsManager)
    }

    init(sessionManager: SessionManager, myUserRepository: MyUserRepository, userRepository: UserRepository,
         listingRepository: ListingRepository, tracker: Tracker, isMyProfile: Bool, user: User?, source: UserSource,
         featureFlags: FeatureFlaggeable, notificationsManager: NotificationsManager) {
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.listingRepository = listingRepository
        self.tracker = tracker
        self.isMyProfile = isMyProfile
        self.user = Variable<User?>(user)
        self.source = source
        self.featureFlags = featureFlags
        self.notificationsManager = notificationsManager
        self.sellingProductListRequester = UserStatusesProductListRequester(statuses: [.pending, .approved],
                                                                            itemsPerPage: Constants.numProductsPerPageDefault)
        self.sellingProductListViewModel = ProductListViewModel(requester: self.sellingProductListRequester)
        self.soldProductListRequester = UserStatusesProductListRequester(statuses: [.sold, .soldOld],
                                                                         itemsPerPage: Constants.numProductsPerPageDefault)
        self.soldProductListViewModel = ProductListViewModel(requester: self.soldProductListRequester)
        self.favoritesProductListRequester = UserFavoritesProductListRequester()
        self.favoritesProductListViewModel = ProductListViewModel(requester: self.favoritesProductListRequester)
        
        self.productListViewModel = Variable<ProductListViewModel>(sellingProductListViewModel)
        self.disposeBag = DisposeBag()
        super.init()
        
        self.sellingProductListViewModel.dataDelegate = self
        self.soldProductListViewModel.dataDelegate = self
        self.favoritesProductListViewModel.dataDelegate = self
        
        setupRxBindings()
        setupPermissionsNotification()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        
        updatePermissionsWarning()
        
        if itsMe {
            refreshMyUserData()
            resetLists()
            if firstTime {
                navBarButtons.value = buildNavBarButtons()
            }
        } else {
            retrieveUserData()
            refreshIfLoading()
        }

        trackVisit()
    }
}


// MARK: - Public methods

extension UserViewModel {
    func refreshSelling() {
        sellingProductListViewModel.retrieveProducts()
    }
    
    func avatarButtonPressed() {
        guard isMyProfile else { return }
        openSettings()
    }
    
    func ratingsButtonPressed() {
        guard featureFlags.userReviews else { return }
        openRatings()
    }
    
    func buildTrustButtonPressed() {
        guard let userAccounts = userAccounts.value, isMyProfile else { return }
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
                                                       description: LGLocalizedString.profileConnectAccountsMessage), completionBlock: nil)
    }
    
    func pushPermissionsWarningPressed() {
        openPushPermissionsAlert()
    }
    
    func shareButtonPressed() {
        guard let socialMessage = socialMessage else { return }
        delegate?.vmShowNativeShare(socialMessage)
        trackShareStart()
    }
}


// MARK: - Private methods
// MARK: > Helpers

extension UserViewModel {
    var isMyUser: Bool {
        guard let myUserId = myUserRepository.myUser?.objectId else { return false }
        guard let userId = user.value?.objectId else { return false }
        return myUserId == userId
    }
    
    var itsMe: Bool {
        return isMyProfile || isMyUser
    }
    
    func buildNavBarButtons() -> [UIAction] {
        var navBarButtons = [UIAction]()
        
        navBarButtons.append(buildShareNavBarAction())
        if isMyProfile {
            navBarButtons.append(buildSettingsNavBarAction())
        } else if sessionManager.loggedIn && !isMyUser {
            navBarButtons.append(buildMoreNavBarAction())
        }
        return navBarButtons
    }
    
    func buildShareNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_share")?.withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in
            self?.shareButtonPressed()
            }, accessibilityId: .userNavBarShareButton)
    }
    
    func buildSettingsNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_settings")?.withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in
            self?.openSettings()
            }, accessibilityId: .userNavBarSettingsButton)
    }
    
    func buildMoreNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_more")?.withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in
            guard let strongSelf = self else { return }
            
            var actions = [UIAction]()
            actions.append(strongSelf.buildReportButton())
            
            if strongSelf.userRelationIsBlocked.value {
                actions.append(strongSelf.buildUnblockButton())
            } else {
                actions.append(strongSelf.buildBlockButton())
            }
            
            strongSelf.delegate?.vmShowUserActionSheet(LGLocalizedString.commonCancel, actions: actions)
            }, accessibilityId: .userNavBarMoreButton)
    }
    
    func buildReportButton() -> UIAction {
        let title = LGLocalizedString.reportUserTitle
        return UIAction(interface: .text(title), action: { [weak self] in
            guard let strongSelf = self, let userReportedId = strongSelf.user.value?.objectId else { return }
            let reportVM = ReportUsersViewModel(origin: .profile, userReportedId: userReportedId)
            strongSelf.delegate?.vmOpenReportUser(reportVM)
        })
    }
    
    func buildBlockButton() -> UIAction {
        let title = LGLocalizedString.chatBlockUser
        return UIAction(interface: .text(title), action: { [weak self] in
            let title = LGLocalizedString.chatBlockUserAlertTitle
            let message = LGLocalizedString.chatBlockUserAlertText
            let cancelLabel = LGLocalizedString.commonCancel
            let actionTitle = LGLocalizedString.chatBlockUserAlertBlockButton
            let action = UIAction(interface: .styledText(actionTitle, .destructive), action: { [weak self] in
                self?.block()
            })
            self?.delegate?.vmShowAlert(title, message: message, cancelLabel: cancelLabel, actions: [action])
        })
    }
    
    func buildUnblockButton() -> UIAction {
        let title = LGLocalizedString.chatUnblockUser
        return UIAction(interface: .text(title), action: { [weak self] in
            self?.unblock()
        })
    }
    
    func resetLists() {
        sellingProductListViewModel.resetUI()
        soldProductListViewModel.resetUI()
        favoritesProductListViewModel.resetUI()
    }
    
    func refreshIfLoading() {
        let listVM = productListViewModel.value
        switch listVM.state {
        case .loading:
            listVM.retrieveProducts()
        case .data, .error, .empty:
            break
        }
    }
    
    func openSettings() {
        profileNavigator?.openSettings()
    }
    
    func openRatings() {
        guard let userId = user.value?.objectId else { return }
        navigator?.openRatingList(userId)
    }
    
    func openPushPermissionsAlert() {
        trackPushPermissionStart()
        let positive = UIAction(interface: .styledText(LGLocalizedString.profilePermissionsAlertOk, .standard),
                                action: { [weak self] in
                                    self?.trackPushPermissionComplete()
                                    LGPushPermissionsManager.sharedInstance.showPushPermissionsAlert(prePermissionType: .profile)
            },
                                accessibilityId: .userPushPermissionOK)
        let negative = UIAction(interface: .styledText(LGLocalizedString.profilePermissionsAlertCancel, .cancel),
                                action: { [weak self] in
                                    self?.trackPushPermissionCancel()
            },
                                accessibilityId: .userPushPermissionCancel)
        delegate?.vmShowAlertWithTitle(LGLocalizedString.profilePermissionsAlertTitle,
                                       text: LGLocalizedString.profilePermissionsAlertMessage,
                                       alertType: .iconAlert(icon: UIImage(named: "custom_permission_profile")),
                                       actions: [negative, positive])
    }
}


// MARK: > Requests

fileprivate extension UserViewModel {
    func retrieveUserData() {
        guard let userId = user.value?.objectId else { return }
        userRepository.show(userId) { [weak self] result in
            guard let user = result.value else { return }
            self?.updateAccounts(user)
            self?.updateRatings(user)
        }
    }
    
    func refreshMyUserData() {
        myUserRepository.refresh(nil) //Completion not required as we're listening rx_myUser
    }
    
    func retrieveUsersRelation() {
        guard let userId = user.value?.objectId else { return }
        guard !itsMe else { return }
        
        userRepository.retrieveUserToUserRelation(userId) { [weak self] result in
            guard let userRelation = result.value else { return }
            self?.userRelationIsBlocked.value = userRelation.isBlocked
            self?.userRelationIsBlockedBy.value = userRelation.isBlockedBy
        }
    }
    
    func block() {
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
    
    func unblock() {
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
}


// MARK: > Rx

fileprivate extension UserViewModel {
    func setupRxBindings() {
        setupUserInfoRxBindings()
        setupUserRelationRxBindings()
        setupTabRxBindings()
        setupProductListViewRxBindings()
        setupShareRxBindings()
    }
    
    func setupUserInfoRxBindings() {
        if itsMe {
            myUserRepository.rx_myUser.bindNext { [weak self] myUser in
                self?.user.value = myUser
                self?.refreshIfLoading()
                }.addDisposableTo(disposeBag)
        }
        
        user.asObservable().subscribeNext { [weak self] user in
            guard let strongSelf = self else { return }
            
            if strongSelf.isMyProfile {
                strongSelf.backgroundColor.value = UIColor.defaultBackgroundColor
                strongSelf.userAvatarPlaceholder.value = LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor,
                                                                                     name: user?.name)
            } else {
                strongSelf.backgroundColor.value = UIColor.backgroundColorForString(user?.objectId)
                strongSelf.userAvatarPlaceholder.value = LetgoAvatar.avatarWithID(user?.objectId, name: user?.name)
            }
            strongSelf.userAvatarURL.value = user?.avatar?.fileURL
            
            strongSelf.updateRatings(user)
            
            strongSelf.userName.value = user?.name
            strongSelf.userLocation.value = user?.postalAddress.cityStateString
            
            strongSelf.headerMode.value = strongSelf.isMyProfile ? .myUser : .otherUser
            
            // If the user has accounts the set them up
            if let user = user {
                strongSelf.updateAccounts(user)
            }
            
            }.addDisposableTo(disposeBag)
    }
    
    func updateAccounts(_ user: User) {
        let facebookAccount = user.facebookAccount
        let googleAccount = user.googleAccount
        let emailAccount = user.emailAccount
        
        let facebookLinked = facebookAccount != nil
        let facebookVerified = facebookAccount?.verified ?? false
        let googleLinked = googleAccount != nil
        let googleVerified = googleAccount?.verified ?? false
        let emailLinked = emailAccount != nil
        let emailVerified = emailAccount?.verified ?? false
        userAccounts.value = UserViewHeaderAccounts(facebookLinked: facebookLinked,
                                                    facebookVerified: facebookVerified,
                                                    googleLinked: googleLinked,
                                                    googleVerified: googleVerified,
                                                    emailLinked: emailLinked,
                                                    emailVerified: emailVerified)
    }
    
    func updateRatings(_ user: User?) {
        guard let user = user else { return }
        if featureFlags.userReviews {
            userRatingAverage.value = user.ratingAverage?.roundNearest(0.5)
            userRatingCount.value = user.ratingCount
        }
    }
    
    func setupUserRelationRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            self?.userRelationIsBlocked.value = false
            self?.userRelationIsBlockedBy.value = false
            self?.retrieveUsersRelation()
            }.addDisposableTo(disposeBag)
        
        Observable.combineLatest(userRelationIsBlocked.asObservable(), userRelationIsBlockedBy.asObservable(),
                                 userName.asObservable()) { (isBlocked, isBlockedBy, userName) -> String? in
                                    if isBlocked {
                                        if let userName = userName {
                                            return LGLocalizedString.profileBlockedByMeLabelWName(userName)
                                        } else {
                                            return LGLocalizedString.profileBlockedByMeLabel
                                        }
                                    } else if isBlockedBy {
                                        return LGLocalizedString.profileBlockedByOtherLabel
                                    }
                                    return nil
            }.bindTo(userRelationText).addDisposableTo(disposeBag)
        
        if !itsMe {
            userRelationText.asObservable().subscribeNext { [weak self] relation in
                guard let strongSelf = self else { return }
                strongSelf.navBarButtons.value = strongSelf.buildNavBarButtons()
                }.addDisposableTo(disposeBag)
        }
    }
    
    func setupTabRxBindings() {
        tab.asObservable().skip(1).map { [weak self] tab -> ProductListViewModel? in
            switch tab {
            case .selling:
                return self?.sellingProductListViewModel
            case .sold:
                return self?.soldProductListViewModel
            case .favorites:
                return self?.favoritesProductListViewModel
            }
            }.subscribeNext { [weak self] viewModel in
                guard let viewModel = viewModel else { return }
                self?.productListViewModel.value = viewModel
                self?.refreshIfLoading()
            }.addDisposableTo(disposeBag)
    }
    
    func setupProductListViewRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            guard self?.sellingProductListRequester.userObjectId != user?.objectId else { return }
            self?.sellingProductListRequester.userObjectId = user?.objectId
            self?.soldProductListRequester.userObjectId = user?.objectId
            self?.favoritesProductListRequester.userObjectId = user?.objectId
            self?.resetLists()
        }.addDisposableTo(disposeBag)

        if itsMe {
            listingRepository.events.bindNext { [weak self] event in
                switch event {
                case let .update(listing):
                    self?.sellingProductListViewModel.update(listing: listing)
                case .sold, .unSold:
                    self?.sellingProductListViewModel.refresh()
                    self?.soldProductListViewModel.refresh()
                case .favorite, .unFavorite:
                    self?.favoritesProductListViewModel.refresh()
                case let .create(listing):
                    self?.sellingProductListViewModel.prepend(listing: listing)
                case let .delete(listingId):
                    self?.sellingProductListViewModel.delete(listingId: listingId)
                    self?.soldProductListViewModel.delete(listingId: listingId)
                }
            }.addDisposableTo(disposeBag)
        }
    }
    
    func setupShareRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            guard let user = user, let itsMe = self?.itsMe else {
                self?.socialMessage = nil
                return
            }
            self?.socialMessage = UserSocialMessage(user: user, itsMe: itsMe)
            }.addDisposableTo(disposeBag)
    }
}


// MARK: - ProductListViewModelDataDelegate

extension UserViewModel: ProductListViewModelDataDelegate {
    func productListMV(_ viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                       error: RepositoryError) {
        guard page == 0 && !hasProducts else { return }
        
        if var emptyViewModel = LGEmptyViewModel.respositoryErrorWithRetry(error,
                                                                           action: { [weak viewModel] in viewModel?.refresh() }) {
            emptyViewModel.icon = nil
            viewModel.setErrorState(emptyViewModel)
        }
    }
    
    func productListVM(_ viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool) {
        guard page == 0 && !hasProducts else { return }
        
        let errTitle: String?
        let errButTitle: String?
        var errButAction: (() -> Void)? = nil
        if viewModel === sellingProductListViewModel {
            errTitle = LGLocalizedString.profileSellingNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileSellingOtherUserNoProductsButton
        } else if viewModel === soldProductListViewModel {
            errTitle = LGLocalizedString.profileSoldNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileSoldOtherNoProductsButton
        } else if viewModel === favoritesProductListViewModel {
            errTitle = LGLocalizedString.profileFavouritesMyUserNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileFavouritesMyUserNoProductsButton
            errButAction = { [weak self] in self?.navigator?.openHome() }
        } else { return }
        
        let emptyViewModel = LGEmptyViewModel(icon: nil, title: errTitle, body: nil, buttonTitle: errButTitle,
                                              action: errButAction, secondaryButtonTitle: nil, secondaryAction: nil, emptyReason: .emptyResults)
        
        viewModel.setEmptyState(emptyViewModel)
    }
    
    func productListVM(_ viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?) {
        guard viewModel === productListViewModel.value else { return } //guarding view model is the selected one
        guard let listing = viewModel.listingAtIndex(index), let requester = viewModel.productListRequester else { return }
        let cellModels = viewModel.objects
        
        let data = ListingDetailData.listingList(listing: listing, cellModels: cellModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        navigator?.openListing(data, source: .profile, showKeyboardOnFirstAppearIfNeeded: false, showShareSheetOnFirstAppearIfNeeded: false)
    }
}


// MARK: Push Permissions

fileprivate extension UserViewModel {
    
    func setupPermissionsNotification() {
        guard isMyProfile else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(updatePermissionsWarning),
                                               name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue), object: nil)
    }
    
    dynamic func updatePermissionsWarning() {
        guard isMyProfile else { return }
        pushPermissionsDisabledWarning.value = !UIApplication.shared.areRemoteNotificationsEnabled
    }
}


// MARK: - SocialSharerDelegate

extension UserViewModel: SocialSharerDelegate {
    
    func shareStartedIn(_ shareType: ShareType) {
        
    }
    
    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        guard state == .completed else { return }
        trackShareComplete(shareType.trackingShareNetwork)
    }
}


// MARK: - Tracking

extension UserViewModel {
    func trackVisit() {
        guard let user = user.value else { return }
        
        let typePage: EventParameterTypePage
        switch source {
        case .tabBar:
            typePage = .tabBar
        case .chat:
            typePage = .chat
        case .productDetail:
            typePage = .productDetail
        case .notifications:
            typePage = .notifications
        case .link:
            typePage = .external
        }
        
        let eventTab: EventParameterTab
        switch tab.value {
        case .selling:
            eventTab = .selling
        case .sold:
            eventTab = .sold
        case .favorites:
            eventTab = .favorites
        }
        let profileType: EventParameterProfileType = isMyUser ? .privateParameter : .publicParameter
        
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
        let profileType: EventParameterProfileType = isMyUser ? .privateParameter : .publicParameter
        let trackerEvent = TrackerEvent.profileShareStart(profileType)
        tracker.trackEvent(trackerEvent)
    }
    
    func trackShareComplete(_ shareNetwork: EventParameterShareNetwork) {
        let profileType: EventParameterProfileType = isMyUser ? .privateParameter : .publicParameter
        let trackerEvent = TrackerEvent.profileShareComplete(profileType, shareNetwork: shareNetwork)
        tracker.trackEvent(trackerEvent)
    }
}
