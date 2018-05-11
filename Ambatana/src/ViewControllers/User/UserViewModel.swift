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
    case listingDetail
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
    
    fileprivate let sellingListingListViewModel: ListingListViewModel
    fileprivate let sellingListingListRequester: UserListingListRequester
    fileprivate let soldListingListViewModel: ListingListViewModel
    fileprivate let soldListingListRequester: UserListingListRequester
    fileprivate let favoritesListingListViewModel: ListingListViewModel
    fileprivate let favoritesListingListRequester: UserListingListRequester
    
    // Input
    let tab = Variable<UserViewHeaderTab>(.selling)
    
    // Output
    let navBarButtons = Variable<[UIAction]>([])
    let backgroundColor = Variable<UIColor>(.clear)
    let headerMode = Variable<UserViewHeaderMode>(.myUser)
    let userAvatarPlaceholder = Variable<UIImage?>(nil)
    let userAvatarURL = Variable<URL?>(nil)
    let userRatingAverage = Variable<Float?>(nil)
    let userRatingCount = Variable<Int?>(nil)
    let userRelationText = Variable<String?>(nil)
    let userName = Variable<String?>(nil)
    let userIsProfessional = Variable<Bool>(false)
    let userIsDummy = Variable<Bool>(false)
    let userLocation = Variable<String?>(nil)
    let userAccounts = Variable<UserViewHeaderAccounts?>(nil)
    let pushPermissionsDisabledWarning = Variable<Bool?>(nil)
    var isMostSearchedItemsEnabled: Bool {
        return featureFlags.mostSearchedDemandedItems.isActive
    }
    
    let listingListViewModel: Variable<ListingListViewModel>
    
    var areDummyUsersEnabled: Bool {
        return featureFlags.dummyUsersInfoProfile.isActive
    }
    
    weak var delegate: UserViewModelDelegate?
    weak var navigator: TabNavigator?
    weak var profileNavigator: ProfileTabNavigator? {
        didSet {
            navigator = profileNavigator
        }
    }
    
    private var sellingListingStatusCode: () -> [ListingStatusCode] = {
        return FeatureFlags.sharedInstance.discardedProducts.isActive ?
            [.pending, .approved, .discarded] : [.pending, .approved]
    }
    
    private var soldListingStatusCode: () -> [ListingStatusCode] = {
        return [.sold, .soldOld]
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
        self.sellingListingListRequester = UserStatusesListingListRequester(statuses: sellingListingStatusCode,
                                                                            itemsPerPage: Constants.numListingsPerPageDefault)
        self.sellingListingListViewModel = ListingListViewModel(requester: self.sellingListingListRequester,
                                                                isPrivateList: true)
        self.soldListingListRequester = UserStatusesListingListRequester(statuses: soldListingStatusCode,
                                                                         itemsPerPage: Constants.numListingsPerPageDefault)
        self.soldListingListViewModel = ListingListViewModel(requester: self.soldListingListRequester,
                                                             isPrivateList: true)
        self.favoritesListingListRequester = UserFavoritesListingListRequester()
        self.favoritesListingListViewModel = ListingListViewModel(requester: self.favoritesListingListRequester,
                                                                  isPrivateList: true)
        
        self.listingListViewModel = Variable<ListingListViewModel>(sellingListingListViewModel)
        self.disposeBag = DisposeBag()
        super.init()
        
        self.sellingListingListViewModel.dataDelegate = self
        self.sellingListingListViewModel.listingCellDelegate = self
        self.soldListingListViewModel.dataDelegate = self
        self.favoritesListingListViewModel.dataDelegate = self
        
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
        sellingListingListViewModel.retrieveListings()
    }
    
    func avatarButtonPressed() {
        guard isMyProfile else { return }
        openSettings()
    }
    
    func ratingsButtonPressed() {
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
    
    var myUserId: String? {
        return myUserRepository.myUser?.objectId
    }
    
    var myUserName: String? {
        return myUserRepository.myUser?.name
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
        sellingListingListViewModel.resetUI()
        soldListingListViewModel.resetUI()
        favoritesListingListViewModel.resetUI()
    }
    
    func refreshIfLoading() {
        let listVM = listingListViewModel.value
        switch listVM.state {
        case .loading:
            listVM.retrieveListings()
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
    
    func openMostSearchedItems() {
        navigator?.openMostSearchedItems(source: .mostSearchedUserProfile, enableSearch: false)
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
            self?.updateDummyInfo(user)
            self?.userIsProfessional.value = user.isProfessional
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
    
    func deleteListing(withId listingId: String) {
        delegate?.vmShowLoading(LGLocalizedString.commonLoading)
        listingRepository.delete(listingId: listingId) { [weak self] result in
            let message: String? = result.error != nil ? LGLocalizedString.productDeleteSendErrorGeneric : nil
            self?.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }
}


// MARK: > Rx

fileprivate extension UserViewModel {
    func setupRxBindings() {
        setupUserInfoRxBindings()
        setupUserRelationRxBindings()
        setupTabRxBindings()
        setupListingListViewRxBindings()
        setupShareRxBindings()
    }
    
    func setupUserInfoRxBindings() {
        if itsMe {
            myUserRepository.rx_myUser.bind { [weak self] myUser in
                self?.user.value = myUser
                self?.refreshIfLoading()
                }.disposed(by: disposeBag)
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
            strongSelf.userIsProfessional.value = user?.type == .pro
            strongSelf.userIsDummy.value = user?.type == .dummy
            
            strongSelf.headerMode.value = strongSelf.isMyProfile ? .myUser : .otherUser
            
            // If the user has accounts the set them up
            if let user = user {
                strongSelf.updateAccounts(user)
            }
            
            }.disposed(by: disposeBag)
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
        userRatingAverage.value = user.ratingAverage?.roundNearest(0.5)
        userRatingCount.value = user.ratingCount
    }
    
    func updateDummyInfo(_ user: User?) {
        guard let user = user else { return }
        userName.value = user.name
        userIsDummy.value = user.type == .dummy
    }
    
    func setupUserRelationRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            self?.userRelationIsBlocked.value = false
            self?.userRelationIsBlockedBy.value = false
            self?.retrieveUsersRelation()
            }.disposed(by: disposeBag)
        
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
            }.bind(to: userRelationText).disposed(by: disposeBag)
        
        if !itsMe {
            userRelationText.asObservable().subscribeNext { [weak self] relation in
                guard let strongSelf = self else { return }
                strongSelf.navBarButtons.value = strongSelf.buildNavBarButtons()
                }.disposed(by: disposeBag)
        }
    }
    
    func setupTabRxBindings() {
        tab.asObservable().skip(1).map { [weak self] tab -> ListingListViewModel? in
            switch tab {
            case .selling:
                return self?.sellingListingListViewModel
            case .sold:
                return self?.soldListingListViewModel
            case .favorites:
                return self?.favoritesListingListViewModel
            }
            }.subscribeNext { [weak self] viewModel in
                guard let viewModel = viewModel else { return }
                self?.listingListViewModel.value = viewModel
                self?.refreshIfLoading()
            }.disposed(by: disposeBag)
    }
    
    func setupListingListViewRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            guard self?.sellingListingListRequester.userObjectId != user?.objectId else { return }
            self?.sellingListingListRequester.userObjectId = user?.objectId
            self?.soldListingListRequester.userObjectId = user?.objectId
            self?.favoritesListingListRequester.userObjectId = user?.objectId
            self?.resetLists()
        }.disposed(by: disposeBag)

        if itsMe {
            listingRepository.events.bind { [weak self] event in
                switch event {
                case let .update(listing):
                    self?.sellingListingListViewModel.update(listing: listing)
                case .sold, .unSold:
                    self?.sellingListingListViewModel.refresh()
                    self?.soldListingListViewModel.refresh()
                case .favorite, .unFavorite:
                    self?.favoritesListingListViewModel.refresh()
                case let .create(listing):
                    self?.sellingListingListViewModel.prepend(listing: listing)
                case let .delete(listingId):
                    self?.sellingListingListViewModel.delete(listingId: listingId)
                    self?.soldListingListViewModel.delete(listingId: listingId)
                }
            }.disposed(by: disposeBag)
        }
    }
    
    func setupShareRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            guard let user = user, let itsMe = self?.itsMe else {
                self?.socialMessage = nil
                return
            }
            self?.socialMessage = UserSocialMessage(user: user,
                                                    itsMe: itsMe,
                                                    myUserId: self?.myUserId,
                                                    myUserName: self?.myUserName)
            }.disposed(by: disposeBag)
    }
}


// MARK: - ListingListViewModelDataDelegate

extension UserViewModel: ListingListViewModelDataDelegate {
    func listingListMV(_ viewModel: ListingListViewModel, didFailRetrievingListingsPage page: UInt, hasListings: Bool,
                       error: RepositoryError) {
        guard page == 0 && !hasListings else { return }
        
        if var emptyViewModel = LGEmptyViewModel.map(from: error, action: { [weak viewModel] in viewModel?.refresh() }) {
            emptyViewModel.icon = nil
            viewModel.setErrorState(emptyViewModel)
        }
    }
    
    func listingListVM(_ viewModel: ListingListViewModel, didSucceedRetrievingListingsPage page: UInt,
                       withResultsCount resultsCount: Int, hasListings: Bool) {
        guard page == 0 && !hasListings else { return }
        
        let errTitle: String?
        let errButTitle: String?
        var errButAction: (() -> Void)? = nil
        if viewModel === sellingListingListViewModel {
            errTitle = LGLocalizedString.profileSellingNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileSellingOtherUserNoProductsButton
        } else if viewModel === soldListingListViewModel {
            errTitle = LGLocalizedString.profileSoldNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileSoldOtherNoProductsButton
        } else if viewModel === favoritesListingListViewModel {
            errTitle = LGLocalizedString.profileFavouritesMyUserNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileFavouritesMyUserNoProductsButton
            errButAction = { [weak self] in self?.navigator?.openHome() }
        } else { return }
        
        let emptyViewModel = LGEmptyViewModel(icon: nil, title: errTitle, body: nil, buttonTitle: errButTitle,
                                              action: errButAction, secondaryButtonTitle: nil, secondaryAction: nil,
                                              emptyReason: .emptyResults, errorCode: nil, errorDescription: nil)
        
        viewModel.setEmptyState(emptyViewModel)
    }
    
    func listingListVM(_ viewModel: ListingListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?) {
        guard viewModel === listingListViewModel.value else { return } //guarding view model is the selected one
        guard let listing = viewModel.listingAtIndex(index), !listing.status.isDiscarded, let requester = viewModel.listingListRequester else { return }
        let cellModels = viewModel.objects
        
        let data = ListingDetailData.listingList(listing: listing, cellModels: cellModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        let source: EventParameterListingVisitSource = viewModel === favoritesListingListViewModel ? .favourite : .profile
        navigator?.openListing(data, source: source, actionOnFirstAppear: .nonexistent)
    }
    
    func vmProcessReceivedListingPage(_ listings: [ListingCellModel], page: UInt) -> [ListingCellModel] { return listings }
    func vmDidSelectSellBanner(_ type: String) {}
    func vmDidSelectCollection(_ type: CollectionCellType) {}
    func vmDidSelectMostSearchedItems() {}
}


// MARK: Push Permissions

fileprivate extension UserViewModel {
    
    func setupPermissionsNotification() {
        guard isMyProfile else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(updatePermissionsWarning),
                                               name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue), object: nil)
    }
    
    @objc func updatePermissionsWarning() {
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
        case .listingDetail:
            typePage = .listingDetail
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

extension UserViewModel: ListingCellDelegate {
    func interestedActionFor(_ listing: Listing) {
        // this is just meant to be inside the MainFeed
        return
    }
        
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
        delegate?.vmShowUserActionSheet(LGLocalizedString.commonCancel, actions: [delete])
    }
    
    func postNowButtonPressed(_ view: UIView) { }
}
