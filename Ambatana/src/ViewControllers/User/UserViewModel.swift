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
    case TabBar
    case ProductDetail
    case Chat
    case Notifications
    case Link
}

protocol UserViewModelDelegate: BaseViewModelDelegate {
    func vmOpenReportUser(reportUserVM: ReportUsersViewModel)
    func vmOpenHome()
    func vmShowUserActionSheet(cancelLabel: String, actions: [UIAction])
    func vmShowNativeShare(socialMessage: SocialMessage)
}

class UserViewModel: BaseViewModel {
    // Constants
    private static let userBgEffectAlphaMax: CGFloat = 0.9
    private static let userBgTintAlphaMax: CGFloat = 0.54

    // Repositories / Managers
    private let sessionManager: SessionManager
    private let myUserRepository: MyUserRepository
    private let userRepository: UserRepository
    private let tracker: Tracker

    // Data & VMs
    private let user: Variable<User?>
    private(set) var isMyProfile: Bool
    private let userRelationIsBlocked = Variable<Bool>(false)
    private let userRelationIsBlockedBy = Variable<Bool>(false)
    private let source: UserSource
    private var socialMessage: SocialMessage? = nil

    private let sellingProductListViewModel: ProductListViewModel
    private let sellingProductListRequester: UserProductListRequester
    private let soldProductListViewModel: ProductListViewModel
    private let soldProductListRequester: UserProductListRequester
    private let favoritesProductListViewModel: ProductListViewModel
    private let favoritesProductListRequester: UserProductListRequester

    // Input
    let tab = Variable<UserViewHeaderTab>(.Selling)

    // Output
    let navBarButtons = Variable<[UIAction]>([])
    let backgroundColor = Variable<UIColor>(UIColor.clearColor())
    let headerMode = Variable<UserViewHeaderMode>(.MyUser)
    let userAvatarPlaceholder = Variable<UIImage?>(nil)
    let userAvatarURL = Variable<NSURL?>(nil)
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

    static func myUserUserViewModel(source: UserSource) -> UserViewModel {
        return UserViewModel(source: source)
    }

    private convenience init(source: UserSource) {
        let sessionManager = Core.sessionManager
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(sessionManager: sessionManager, myUserRepository: myUserRepository, userRepository: userRepository,
            tracker: tracker, isMyProfile: true, user: nil, source: source)
    }

    convenience init(user: User, source: UserSource) {
        let sessionManager = Core.sessionManager
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(sessionManager: sessionManager, myUserRepository: myUserRepository, userRepository: userRepository,
            tracker: tracker, isMyProfile: false, user: user, source: source)
    }
    
    convenience init(chatInterlocutor: ChatInterlocutor, source: UserSource) {
        let sessionManager = Core.sessionManager
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        let user = userRepository.build(fromChatInterlocutor: chatInterlocutor)
        self.init(sessionManager: sessionManager, myUserRepository: myUserRepository, userRepository: userRepository,
                  tracker: tracker, isMyProfile: false, user: user, source: source)
    }

    init(sessionManager: SessionManager, myUserRepository: MyUserRepository, userRepository: UserRepository,
        tracker: Tracker, isMyProfile: Bool, user: User?, source: UserSource) {
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.tracker = tracker
        self.isMyProfile = isMyProfile
        self.user = Variable<User?>(user)
        self.source = source

        self.sellingProductListRequester = UserStatusesProductListRequester(statuses: [.Pending, .Approved],
                                                                            itemsPerPage: Constants.numProductsPerPageDefault)
        self.sellingProductListViewModel = ProductListViewModel(requester: self.sellingProductListRequester)
        self.soldProductListRequester = UserStatusesProductListRequester(statuses: [.Sold, .SoldOld],
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

        updatePermissionsWarning()

        if itsMe {
            resetLists()
        } else {
            retrieveUserAccounts()
        }

        refreshIfLoading()
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
        guard FeatureFlags.userReviews else { return }
        openRatings()
    }

    func buildTrustButtonPressed() {
        guard let userAccounts = userAccounts.value where isMyProfile else { return }
        var verifyTypes: [VerificationType] = []
        if !userAccounts.emailVerified {
            verifyTypes.append(.Email(myUserRepository.myUser?.email))
        }
        if !userAccounts.facebookVerified {
            verifyTypes.append(.Facebook)
        }
        if !userAccounts.googleVerified {
            verifyTypes.append(.Google)
        }
        guard !verifyTypes.isEmpty else { return }
        navigator?.openVerifyAccounts(verifyTypes,
                                         source: .Profile(title: LGLocalizedString.chatConnectAccountsTitle,
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
    private var isMyUser: Bool {
        guard let myUserId = myUserRepository.myUser?.objectId else { return false }
        guard let userId = user.value?.objectId else { return false }
        return myUserId == userId
    }

    private var itsMe: Bool {
        return isMyProfile || isMyUser
    }

    private func buildNavBarButtons() -> [UIAction] {
        var navBarButtons = [UIAction]()

        navBarButtons.append(buildShareNavBarAction())
        if isMyProfile {
            navBarButtons.append(buildSettingsNavBarAction())
        } else if sessionManager.loggedIn && !isMyUser {
            navBarButtons.append(buildMoreNavBarAction())
        }
        return navBarButtons
    }

    private func buildShareNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_share")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            self?.shareButtonPressed()
        }, accessibilityId: .UserNavBarShareButton)
    }

    private func buildSettingsNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_settings")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            self?.openSettings()
        }, accessibilityId: .UserNavBarSettingsButton)
    }

    private func buildMoreNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_more")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            guard let strongSelf = self else { return }

            var actions = [UIAction]()
            actions.append(strongSelf.buildReportButton())

            if strongSelf.userRelationIsBlocked.value {
                actions.append(strongSelf.buildUnblockButton())
            } else {
                actions.append(strongSelf.buildBlockButton())
            }

            strongSelf.delegate?.vmShowUserActionSheet(LGLocalizedString.commonCancel, actions: actions)
        }, accessibilityId: .UserNavBarMoreButton)
    }

    private func buildReportButton() -> UIAction {
        let title = LGLocalizedString.reportUserTitle
        return UIAction(interface: .Text(title), action: { [weak self] in
            guard let strongSelf = self, userReportedId = strongSelf.user.value?.objectId else { return }
            let reportVM = ReportUsersViewModel(origin: .Profile, userReportedId: userReportedId)
            strongSelf.delegate?.vmOpenReportUser(reportVM)
        })
    }

    private func buildBlockButton() -> UIAction {
        let title = LGLocalizedString.chatBlockUser
        return UIAction(interface: .Text(title), action: { [weak self] in
            let title = LGLocalizedString.chatBlockUserAlertTitle
            let message = LGLocalizedString.chatBlockUserAlertText
            let cancelLabel = LGLocalizedString.commonCancel
            let actionTitle = LGLocalizedString.chatBlockUserAlertBlockButton
            let action = UIAction(interface: .StyledText(actionTitle, .Destructive), action: { [weak self] in
                self?.block()
            })
            self?.delegate?.vmShowAlert(title, message: message, cancelLabel: cancelLabel, actions: [action])
        })
    }

    private func buildUnblockButton() -> UIAction {
        let title = LGLocalizedString.chatUnblockUser
        return UIAction(interface: .Text(title), action: { [weak self] in
            self?.unblock()
        })
    }

    private func resetLists() {
        sellingProductListViewModel.resetUI()
        soldProductListViewModel.resetUI()
        favoritesProductListViewModel.resetUI()
    }

    private func refreshIfLoading() {
        let listVM = productListViewModel.value
        switch listVM.state {
        case .Loading:
            listVM.retrieveProducts()
        case .Data, .Error, .Empty:
            break
        }
    }

    private func openSettings() {
        profileNavigator?.openSettings()
    }

    private func openRatings() {
        guard let userId = user.value?.objectId else { return }
        navigator?.openRatingList(userId)
    }

    private func openPushPermissionsAlert() {
        trackPushPermissionStart()
        let positive = UIAction(interface: .StyledText(LGLocalizedString.profilePermissionsAlertOk, .Default),
                                action: { [weak self] in
                                    self?.trackPushPermissionComplete()
                                    PushPermissionsManager.sharedInstance.showPushPermissionsAlert(prePermissionType: .Profile)
                                },
                                accessibilityId: .UserPushPermissionOK)
        let negative = UIAction(interface: .StyledText(LGLocalizedString.profilePermissionsAlertCancel, .Cancel),
                                action: { [weak self] in
                                    self?.trackPushPermissionCancel()
                                },
                                accessibilityId: .UserPushPermissionCancel)
        delegate?.vmShowAlertWithTitle(LGLocalizedString.profilePermissionsAlertTitle,
                                       text: LGLocalizedString.profilePermissionsAlertMessage,
                                       alertType: .IconAlert(icon: UIImage(named: "custom_permission_profile")),
                                       actions: [negative, positive])
    }
}


// MARK: > Requests

extension UserViewModel {
    private func retrieveUserAccounts() {
        guard userAccounts.value == nil else { return }
        guard let userId = user.value?.objectId else { return }
        userRepository.show(userId, includeAccounts: true) { [weak self] result in
            guard let user = result.value else { return }
            self?.updateAccounts(user)
        }
    }

    private func retrieveUsersRelation() {
        guard let userId = user.value?.objectId else { return }
        guard !itsMe else { return }

        userRepository.retrieveUserToUserRelation(userId) { [weak self] result in
            guard let userRelation = result.value else { return }
            self?.userRelationIsBlocked.value = userRelation.isBlocked
            self?.userRelationIsBlockedBy.value = userRelation.isBlockedBy
        }
    }

    private func block() {
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

    private func unblock() {
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

extension UserViewModel {
    private func setupRxBindings() {
        setupUserInfoRxBindings()
        setupUserRelationRxBindings()
        setupTabRxBindings()
        setupProductListViewRxBindings()
        setupShareRxBindings()
    }

    private func setupUserInfoRxBindings() {
        if itsMe {
            myUserRepository.rx_myUser.asObservable().bindNext { [weak self] myUser in
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

            if FeatureFlags.userReviews {
                strongSelf.userRatingAverage.value = user?.ratingAverage?.roundNearest(0.5)
                strongSelf.userRatingCount.value = user?.ratingCount
            }

            strongSelf.userName.value = user?.name
            strongSelf.userLocation.value = user?.postalAddress.cityStateString

            strongSelf.headerMode.value = strongSelf.isMyProfile ? .MyUser : .OtherUser

            // If the user has accounts the set them up
            if let user = user, _ = user.accounts {
                strongSelf.updateAccounts(user)
            }

        }.addDisposableTo(disposeBag)
    }

    private func updateAccounts(user: User) {
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

    private func setupUserRelationRxBindings() {
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

        userRelationText.asObservable().subscribeNext { [weak self] relation in
            guard let strongSelf = self else { return }
            strongSelf.navBarButtons.value = strongSelf.buildNavBarButtons()
        }.addDisposableTo(disposeBag)
    }

    private func setupTabRxBindings() {
        tab.asObservable().skip(1).map { [weak self] tab -> ProductListViewModel? in
            switch tab {
            case .Selling:
                return self?.sellingProductListViewModel
            case .Sold:
                return self?.soldProductListViewModel
            case .Favorites:
                return self?.favoritesProductListViewModel
            }
        }.subscribeNext { [weak self] viewModel in
            guard let viewModel = viewModel else { return }
            self?.productListViewModel.value = viewModel
            self?.refreshIfLoading()
        }.addDisposableTo(disposeBag)
    }

    private func setupProductListViewRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            guard self?.sellingProductListRequester.userObjectId != user?.objectId else { return }
            self?.sellingProductListRequester.userObjectId = user?.objectId
            self?.soldProductListRequester.userObjectId = user?.objectId
            self?.favoritesProductListRequester.userObjectId = user?.objectId
            self?.resetLists()
        }.addDisposableTo(disposeBag)
    }

    private func setupShareRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            guard let user = user, itsMe = self?.itsMe else {
                self?.socialMessage = nil
                return
            }
            self?.socialMessage = UserSocialMessage(user: user, itsMe: itsMe)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - ProductListViewModelDataDelegate

extension UserViewModel: ProductListViewModelDataDelegate {
    func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                       error: RepositoryError) {
        guard page == 0 && !hasProducts else { return }

        var emptyViewModel = LGEmptyViewModel.respositoryErrorWithRetry(error,
                                                            action: { [weak viewModel] in viewModel?.refresh() })
        emptyViewModel.icon = nil

        viewModel.setErrorState(emptyViewModel)
    }

    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool) {
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
            errButAction = { [weak self] in self?.delegate?.vmOpenHome() }
        } else { return }

        let emptyViewModel = LGEmptyViewModel(icon: nil, title: errTitle, body: nil, buttonTitle: errButTitle,
                                              action: errButAction, secondaryButtonTitle: nil, secondaryAction: nil)

        viewModel.setEmptyState(emptyViewModel)
    }

    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?) {
        guard viewModel === productListViewModel.value else { return } //guarding view model is the selected one
        guard let product = viewModel.productAtIndex(index), requester = viewModel.productListRequester else { return }
        let cellModels = viewModel.objects

        let data = ProductDetailData.ProductList(product: product, cellModels: cellModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        navigator?.openProduct(data, source: .Profile)
    }
}


// MARK: Push Permissions

private extension UserViewModel {

    func setupPermissionsNotification() {
        guard isMyProfile else { return }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePermissionsWarning),
                        name: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue, object: nil)
    }

    dynamic func updatePermissionsWarning() {
        guard isMyProfile else { return }
        pushPermissionsDisabledWarning.value = !UIApplication.sharedApplication().areRemoteNotificationsEnabled
    }
}


// MARK: - SocialSharerDelegate

extension UserViewModel: SocialSharerDelegate {

    func shareStartedIn(shareType: ShareType) {

    }

    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState) {
        guard state == .Completed else { return }
        trackShareComplete(shareType.trackingShareNetwork)
    }
}


// MARK: - Tracking

extension UserViewModel {
    private func trackVisit() {
        guard let user = user.value else { return }

        let typePage: EventParameterTypePage
        switch source {
        case .TabBar:
            typePage = .TabBar
        case .Chat:
            typePage = .Chat
        case .ProductDetail:
            typePage = .ProductDetail
        case .Notifications:
            typePage = .Notifications
        case .Link:
            typePage = .External
        }

        let eventTab: EventParameterTab
        switch tab.value {
        case .Selling:
            eventTab = .Selling
        case .Sold:
            eventTab = .Sold
        case .Favorites:
            eventTab = .Favorites
        }
        let profileType: EventParameterProfileType = isMyUser ? .Private : .Public
        
        let event = TrackerEvent.profileVisit(user, profileType: profileType, typePage: typePage, tab: eventTab)
        tracker.trackEvent(event)
    }

    private func trackBlock(userId: String) {
        let event = TrackerEvent.profileBlock(.Profile, blockedUsersIds: [userId])
        tracker.trackEvent(event)
    }

    private func trackUnblock(userId: String) {
        let event = TrackerEvent.profileUnblock(.Profile, unblockedUsersIds: [userId])
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    private func trackPushPermissionStart() {
        let goToSettings: EventParameterPermissionGoToSettings =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .True : .NotAvailable
        let trackerEvent = TrackerEvent.permissionAlertStart(.Push, typePage: .Profile, alertType: .Custom,
                                                             permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    private func trackPushPermissionComplete() {
        let goToSettings: EventParameterPermissionGoToSettings =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .True : .NotAvailable
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Push, typePage: .Profile, alertType: .Custom,
                                                                permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    private func trackPushPermissionCancel() {
        let goToSettings: EventParameterPermissionGoToSettings =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .True : .NotAvailable
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Push, typePage: .Profile, alertType: .Custom,
                                                              permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    private func trackShareStart() {
        let profileType: EventParameterProfileType = isMyUser ? .Private : .Public
        let trackerEvent = TrackerEvent.profileShareStart(profileType)
        tracker.trackEvent(trackerEvent)
    }

    private func trackShareComplete(shareNetwork: EventParameterShareNetwork) {
        let profileType: EventParameterProfileType = isMyUser ? .Private : .Public
        let trackerEvent = TrackerEvent.profileShareComplete(profileType, shareNetwork: shareNetwork)
        tracker.trackEvent(trackerEvent)
    }
}
