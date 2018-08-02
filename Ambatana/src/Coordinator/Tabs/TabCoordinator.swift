import LGCoreKit
import RxSwift
import LGComponents

protocol TabCoordinatorDelegate: class {
    func tabCoordinator(_ tabCoordinator: TabCoordinator, setSellButtonHidden hidden: Bool, animated: Bool)
}

class TabCoordinator: NSObject, Coordinator {
    var child: Coordinator?
    var viewController: UIViewController {
        return navigationController
    }
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    var bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    let rootViewController: UIViewController
    let navigationController: UINavigationController

    var deckAnimator: DeckAnimator?

    private let listingCoordinator: ListingCoordinator
    private let userCoordinator: UserCoordinator

    let listingRepository: ListingRepository
    let userRepository: UserRepository
    let chatRepository: ChatRepository
    let myUserRepository: MyUserRepository
    let installationRepository: InstallationRepository
    let keyValueStorage: KeyValueStorage
    let tracker: Tracker
    let featureFlags: FeatureFlaggeable
    let disposeBag = DisposeBag()

    private let deeplinkMailBox: DeepLinkMailBox

    private lazy var verificationAssembly: UserVerificationAssembly = LGUserVerificationBuilder.standard(nav: self.navigationController)

    weak var tabCoordinatorDelegate: TabCoordinatorDelegate?
    weak var appNavigator: AppNavigator?

    fileprivate var interactiveTransitioner: UIPercentDrivenInteractiveTransition?

    // MARK: - Lifecycle

    init(listingRepository: ListingRepository, userRepository: UserRepository, chatRepository: ChatRepository,
         myUserRepository: MyUserRepository, installationRepository: InstallationRepository,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage, tracker: Tracker, rootViewController: UIViewController,
         featureFlags: FeatureFlaggeable, sessionManager: SessionManager, deeplinkMailBox: DeepLinkMailBox) {
        self.listingRepository = listingRepository
        self.userRepository = userRepository
        self.chatRepository = chatRepository
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
        self.bubbleNotificationManager = bubbleNotificationManager
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.rootViewController = rootViewController
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager
        self.navigationController = UINavigationController(rootViewController: rootViewController)
        self.listingCoordinator = ListingCoordinator(navigationController: navigationController)
        self.userCoordinator = UserCoordinator(navigationController: navigationController)
        self.deeplinkMailBox = deeplinkMailBox

        super.init()

        self.listingCoordinator.listingDetailNavigator = self
        self.navigationController.delegate = self
    }


    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {}
    func dismissViewController(animated: Bool, completion: (() -> Void)?) {}

    func isShowingConversation(_ conversationId: String) -> Bool {
        if let conversationIdDisplayer = navigationController.viewControllers.last as? ConversationIdDisplayer {
            return conversationIdDisplayer.isDisplayingConversationId(conversationId)
        }
        return false
    }

    func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
        return !viewController.isRootViewController()
    }
}


// MARK: - TabNavigator

extension TabCoordinator: TabNavigator {

    func openHome() {
        appNavigator?.openHome()
    }

    func openSell(source: PostingSource, postCategory: PostCategory?) {
        appNavigator?.openSell(source: source, postCategory: postCategory, listingTitle: nil)
    }

    func openUserRating(_ source: RateUserSource, data: RateUserData) {
        appNavigator?.openUserRating(source, data: data)
    }

    func openUser(_ data: UserDetailData) {
        switch data {
        case let .id(userId, source):
            openUser(userId: userId, source: source)
        case let .userAPI(user, source):
            openUser(user: user, source: source)
        case let .userChat(user):
            openUser(user)
        }
    }

    func openListing(_ data: ListingDetailData, source: EventParameterListingVisitSource, actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        listingCoordinator.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }

    func openChat(_ data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?) {
        switch data {
        case let .conversation(conversation):
            openConversation(conversation, source: source, predefinedMessage: predefinedMessage)
        case .inactiveConversations:
            openInactiveConversations()
        case let .inactiveConversation(conversation):
            openInactiveConversation(conversation: conversation)
        case let .listingAPI(listing):
            openListingChat(listing, source: source, interlocutor: nil)
        case let .dataIds(conversationId):
            openChatFromConversationId(conversationId, source: source, predefinedMessage: predefinedMessage)
        }
    }

    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {
        appNavigator?.openVerifyAccounts(types, source: source, completionBlock: completionBlock)
    }
    
    func openAppInvite(myUserId: String?, myUserName: String?) {
        appNavigator?.openAppInvite(myUserId: myUserId, myUserName: myUserName)
    }

    func canOpenAppInvite() -> Bool {
        return appNavigator?.canOpenAppInvite() ?? false
    }

    func openRatingList(_ userId: String) {
        let vm = UserRatingListViewModel(userId: userId, tabNavigator: self)
        let vc = UserRatingListViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func openDeepLink(_ deeplink: DeepLink) {
        appNavigator?.openDeepLink(deepLink: deeplink)
    }

    func openUserVerificationView() {
        let vc = verificationAssembly.buildUserVerification()
        navigationController.pushViewController(vc, animated: true)
    }

    func openUser(user: User, source: UserSource) {
        userCoordinator.openUser(user: user, source: source)
    }

    var hidesBottomBarWhenPushed: Bool {
        return navigationController.viewControllers.count == 1
    }

    func openCommunityTab() {
        appNavigator?.openCommunityTab()
    }
}

fileprivate extension TabCoordinator {
    func openUser(userId: String, source: UserSource) {
        navigationController.showLoadingMessageAlert()
        userRepository.show(userId) { [weak self] result in
            if let user = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openUser(user: user, source: source)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .network:
                    message = R.Strings.commonErrorConnectionFailed
                case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
                     .wsChatError, .searchAlertError:
                    message = R.Strings.commonUserNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message: message)
                }
            }
        }
    }

    func openUser(_ interlocutor: ChatInterlocutor) {
        userCoordinator.openUser(interlocutor, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
    }

    func openConversation(_ conversation: ChatConversation, source: EventParameterTypePage, predefinedMessage: String?) {
        let vm = ChatViewModel(conversation: conversation, navigator: self, source: source, predefinedMessage: predefinedMessage)
        let vc = ChatViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openInactiveConversations() {
        let vm = ChatInactiveConversationsListViewModel(navigator: self)
        let vc = ChatInactiveConversationsListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openInactiveConversation(conversation: ChatInactiveConversation) {
        let vm = ChatInactiveConversationDetailsViewModel(conversation: conversation)
        let vc = ChatInactiveConversationDetailsViewController(viewModel: vm)
        vm.delegate = vc
        vm.navigator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func openChatFrom(listing: Listing,
                      source: EventParameterTypePage,
                      openChatAutomaticMessage: ChatWrapperMessageType?,
                      interlocutor: User?) {
        guard let chatVM = ChatViewModel(listing: listing,
                                         navigator: self,
                                         source: source,
                                         openChatAutomaticMessage: openChatAutomaticMessage,
                                         interlocutor: interlocutor) else { return }
        let chatVC = ChatViewController(viewModel: chatVM, hidesBottomBar: source == .listingListFeatured)
        navigationController.pushViewController(chatVC, animated: true)
    }

    func openChatFromConversationId(_ conversationId: String, source: EventParameterTypePage, predefinedMessage: String?) {
        navigationController.showLoadingMessageAlert()

        let completion: ChatConversationCompletion = { [weak self] result in
            self?.navigationController.dismissLoadingMessageAlert { [weak self] in
                if let conversation = result.value {
                    self?.openConversation(conversation, source: source, predefinedMessage: predefinedMessage)
                } else if let error = result.error {
                    self?.showChatRetrieveError(error)
                }
            }
        }

        chatRepository.showConversation(conversationId, completion: completion)
    }

    func showChatRetrieveError(_ error: RepositoryError) {
        let message: String
        switch error {
        case .network:
            message = R.Strings.commonErrorConnectionFailed
        case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .wsChatError, .searchAlertError:
            message = R.Strings.commonChatNotAvailable
        }
        navigationController.showAutoFadingOutMessageAlert(message: message)
    }
}
extension TabCoordinator: ChatInactiveConversationsListNavigator {}

extension TabCoordinator {
    func openEditUserBio() {
        let router = UserVerificationRouter(navigationController: navigationController)
        router.openEditUserBio()
    }
}

// MARK: > ListingDetailNavigator

extension TabCoordinator: ListingDetailNavigator {
    func openAppRating(_ source: EventParameterRatingSource) {
        guard let url = URL.makeAppRatingDeeplink(with: source) else { return }
        deeplinkMailBox.push(convertible: url)
    }

    func openVideoPlayer(atIndex index: Int, listingVM: ListingViewModel, source: EventParameterListingVisitSource) {
        guard let coordinator = VideoPlayerCoordinator(atIndex: index, listingVM: listingVM, source: source) else {
            return
        }
        openChild(coordinator: coordinator,
                  parent: rootViewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }

    func closeProductDetail() {
        navigationController.popViewController(animated: true)
    }

    func editListing(_ listing: Listing,
                     bumpUpProductData: BumpUpProductData?,
                     listingCanBeBoosted: Bool,
                     timeSinceLastBump: TimeInterval?,
                     maxCountdown: TimeInterval) {
        let navigator = EditListingCoordinator(listing: listing,
                                               bumpUpProductData: bumpUpProductData,
                                               pageType: nil,
                                               listingCanBeBoosted: listingCanBeBoosted,
                                               timeSinceLastBump: timeSinceLastBump,
                                               maxCountdown: maxCountdown)
        navigator.delegate = self
        openChild(coordinator: navigator,
                  parent: rootViewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }

    func openListingChat(_ listing: Listing, source: EventParameterTypePage, interlocutor: User?) {
        openChatFrom(listing: listing, source: source, openChatAutomaticMessage: nil, interlocutor: interlocutor)
    }

    func closeListingAfterDelete(_ listing: Listing) {
        closeProductDetail()
        if (listing.status != .sold) && (listing.status != .soldOld) {
            let action = UIAction(interface: .button(R.Strings.productDeletePostButtonTitle,
                                                     .primary(fontSize: .medium)), action: { [weak self] in
                                                        self?.openSell(source: .deleteListing, postCategory: nil)
                }, accessibility: AccessibilityId.postDeleteAlertButton)
            navigationController.showAlertWithTitle(R.Strings.productDeletePostTitle,
                                                    text: R.Strings.productDeletePostSubtitle,
                                                    alertType: .plainAlertOld, actions: [action])
        }
    }

    func openFreeBumpUp(forListing listing: Listing,
                        bumpUpProductData: BumpUpProductData,
                        typePage: EventParameterTypePage?,
                        maxCountdown: TimeInterval) {
        let bumpCoordinator = BumpUpCoordinator(listing: listing,
                                                bumpUpProductData: bumpUpProductData,
                                                typePage: typePage,
                                                maxCountdown: maxCountdown)
        openChild(coordinator: bumpCoordinator,
                  parent: rootViewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }

    func openPayBumpUp(forListing listing: Listing,
                       bumpUpProductData: BumpUpProductData,
                       typePage: EventParameterTypePage?,
                       maxCountdown: TimeInterval) {
        let bumpCoordinator = BumpUpCoordinator(listing: listing,
                                                bumpUpProductData: bumpUpProductData,
                                                typePage: typePage,
                                                maxCountdown: maxCountdown)
        openChild(coordinator: bumpCoordinator,
                  parent: rootViewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }

    func openBumpUpBoost(forListing listing: Listing,
                         bumpUpProductData: BumpUpProductData,
                         typePage: EventParameterTypePage?,
                         timeSinceLastBump: TimeInterval,
                         maxCountdown: TimeInterval) {
        let bumpCoordinator = BumpUpCoordinator(listing: listing,
                                                bumpUpProductData: bumpUpProductData,
                                                typePage: typePage,
                                                timeSinceLastBump: timeSinceLastBump,
                                                maxCountdown: maxCountdown)
        openChild(coordinator: bumpCoordinator, parent: rootViewController, animated: true, forceCloseChild: true, completion: nil)
    }

    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo) {
        let ratingCoordinator = UserRatingCoordinator(source: source,
                                                      buyers: buyers,
                                                      listingId: listingId,
                                                      sourceRateBuyers: sourceRateBuyers,
                                                      trackingInfo: trackingInfo)
        ratingCoordinator.delegate = self
        openChild(coordinator: ratingCoordinator, parent: rootViewController, animated: true, forceCloseChild: true, completion: nil)
    }

    func showProductFavoriteBubble(with data: BubbleNotificationData) {
        showBubble(with: data, duration: SharedConstants.bubbleFavoriteDuration)
    }

    func openLoginIfNeededFromProductDetail(from: EventParameterLoginSourceValue,
                                            infoMessage: String,
                                            loggedInAction: @escaping (() -> Void)) {
        openLoginIfNeeded(from: from,
                          style: .popup(infoMessage),
                          loggedInAction: loggedInAction,
                          cancelAction: nil)
    }

    func showBumpUpNotAvailableAlertWithTitle(title: String,
                                              text: String,
                                              alertType: AlertType,
                                              buttonsLayout: AlertButtonsLayout,
                                              actions: [UIAction]) {
        navigationController.showAlertWithTitle(title,
                                                text: text,
                                                alertType: alertType,
                                                buttonsLayout: buttonsLayout,
                                                actions: actions)
    }

    func showBumpUpBoostSucceededAlert() {
        let boostSuccessAlert = BoostSuccessAlertView()
        // the alert view has a thin blur that has to cover the nav bar too
        navigationController.view.addSubviewForAutoLayout(boostSuccessAlert)
        boostSuccessAlert.layout(with: navigationController.view).fill()
        boostSuccessAlert.alpha = 0
        navigationController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            boostSuccessAlert.alpha = 1
            boostSuccessAlert.startAnimation()
        }
    }

    func openContactUs(forListing listing: Listing, contactUstype: ContactUsType) {
        guard let user = myUserRepository.myUser,
            let installation = installationRepository.installation,
            let contactURL = LetgoURLHelper.buildContactUsURL(user: user, installation: installation, listing: listing, type: contactUstype) else {
                return
        }
        rootViewController.openInAppWebViewWith(url: contactURL)
    }

    func openFeaturedInfo() {
        let featuredInfoVM = FeaturedInfoViewModel()
        featuredInfoVM.navigator = self
        let featuredInfoVC = FeaturedInfoViewController(viewModel: featuredInfoVM)

        rootViewController.present(featuredInfoVC, animated: true, completion: nil)
    }

    func closeFeaturedInfo() {
        rootViewController.dismiss(animated: true, completion: nil)
    }

    func openAskPhoneFor(listing: Listing, interlocutor: User?) {
        let askNumVM = ProfessionalDealerAskPhoneViewModel(listing: listing, interlocutor: interlocutor, typePage: .listingDetail)
        askNumVM.navigator = self
        let askNumVC = ProfessionalDealerAskPhoneViewController(viewModel: askNumVM)
        askNumVC.setupForModalWithNonOpaqueBackground()
        rootViewController.present(askNumVC, animated: true, completion: nil)
    }

    func closeAskPhoneFor(listing: Listing, openChat: Bool, withPhoneNum: String?, source: EventParameterTypePage,
                          interlocutor: User?) {
        var completion: (()->())? = nil
        if openChat {
            completion = { [weak self] in
                var openChatAutomaticMessage: ChatWrapperMessageType? = nil
                if let phone = withPhoneNum {
                    openChatAutomaticMessage = .phone(phone)
                }
                self?.openChatFrom(listing: listing,
                                   source: source,
                                   openChatAutomaticMessage: openChatAutomaticMessage,
                                   interlocutor: interlocutor)
            }
        }
        rootViewController.dismiss(animated: true, completion: completion)
        tabCoordinatorDelegate?.tabCoordinator(self,
                                               setSellButtonHidden: false,
                                               animated: false)
    }

    func openUserReport(source: EventParameterTypePage, userReportedId: String) {
        let vm = ReportUsersViewModel(origin: source, userReportedId: userReportedId)
        let vc = ReportUsersViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func showUndoBubble(withMessage message: String,
                        duration: TimeInterval,
                        withAction action: @escaping () -> ()) {
        let action = UIAction(interface: .button(R.Strings.productInterestedUndo, .terciary) , action: action)
        let data = BubbleNotificationData(text: message, action: action)
        
        switch featureFlags.highlightedIAmInterestedInFeed {
        case .baseline, .control:
            bubbleNotificationManager.showBubble(data: data,
                                                 duration: duration,
                                                 view: navigationController.view,
                                                 alignment: .top(offset: viewController.statusBarHeight),
                                                 style: .light)
        case .darkTop:
            bubbleNotificationManager.showBubble(data: data,
                                                 duration: duration,
                                                 view: navigationController.view,
                                                 alignment: .top(offset: viewController.statusBarHeight),
                                                 style: .dark)
        case .lightBottom:
            appNavigator?.showBottomBubbleNotification(data: data,
                                                       duration: duration,
                                                       alignment: .bottom,
                                                       style: .light)
        case .darkBottom:
            appNavigator?.showBottomBubbleNotification(data: data,
                                                       duration: duration,
                                                       alignment: .bottom,
                                                       style: .dark)
        }
    }
    
    
    func openListingAttributeTable(withViewModel viewModel: ListingAttributeTableViewModel) {
        let viewController = ListingAttributeTableViewController(withViewModel: viewModel)
        rootViewController.present(viewController,
                                   animated: true,
                                   completion: nil)
    }
    
    func closeListingAttributeTable() {
        rootViewController.dismiss(animated: true,
                                   completion: nil)
    }
}

// MARK: > ChatDetailNavigator

extension TabCoordinator: ChatDetailNavigator {
    func navigate(with convertible: DeepLinkConvertible) {
        deeplinkMailBox.push(convertible: convertible)
    }

    func closeChatDetail() {
        navigationController.popViewController(animated: true)
    }

    func openExpressChat(_ listings: [Listing], sourceListingId: String, manualOpen: Bool) {
        guard let expressChatCoordinator = ExpressChatCoordinator(listings: listings, sourceProductId: sourceListingId, manualOpen: manualOpen) else { return }
        expressChatCoordinator.delegate = self
        openChild(coordinator: expressChatCoordinator, parent: rootViewController, animated: true, forceCloseChild: false, completion: nil)
    }

    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void)) {
        openLoginIfNeeded(from: from, style: .popup(R.Strings.chatLoginPopupText),
                          loggedInAction: loggedInAction, cancelAction: nil)
    }

    func openAssistantFor(listingId: String, dataDelegate: MeetingAssistantDataDelegate) {
        let meetingAssistantVM = MeetingAssistantViewModel(listingId: listingId)
        meetingAssistantVM.dataDelegate = dataDelegate
        let meetingAssistantCoord = MeetingAssistantCoordinator(viewModel: meetingAssistantVM)
        openChild(coordinator: meetingAssistantCoord, parent: rootViewController, animated: true, forceCloseChild: true, completion: nil)
    }
}

// MARK: > ChatInactiveDetailNavigator

extension TabCoordinator: ChatInactiveDetailNavigator {
    func closeChatInactiveDetail() {
        navigationController.popViewController(animated: true)
    }
}


// MARK: - UINavigationControllerDelegate

extension TabCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                                  to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animator = (toVC as? AnimatableTransition)?.animator, operation == .push {
            animator.pushing = true
            return animator
        } else if let animator = (fromVC as? AnimatableTransition)?.animator, operation == .pop {
            animator.pushing = false
            return animator
        } else if let transitioner = deckAnimator?.animatedTransitionings(for: operation, from: fromVC, to: toVC) {
            return transitioner
        } else {
            return nil
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        tabCoordinatorDelegate?.tabCoordinator(self,
                                               setSellButtonHidden: shouldHideSellButtonAtViewController(viewController),
                                               animated: false)
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {
        if let main = viewController as? MainListingsViewController {
            main.tabBarController?.setTabBarHidden(false, animated: true)
        } else if let photoViewer = viewController as? PhotoViewerViewController {
            let leftGesture = UIScreenEdgePanGestureRecognizer(target: self,
                                                               action: #selector(handlePhotoViewerEdgeGesture))
            leftGesture.edges = .left
            photoViewer.addEdgeGesture([leftGesture])
        }
        tabCoordinatorDelegate?.tabCoordinator(self,
                                               setSellButtonHidden: shouldHideSellButtonAtViewController(viewController),
                                               animated: true)
    }

    @objc func handlePhotoViewerEdgeGesture(gesture: UIScreenEdgePanGestureRecognizer) {
        deckAnimator?.handlePhotoViewerEdgeGesture(gesture)
    }

    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let animator = animationController as? PhotoViewerTransitionAnimator,
            animator.isInteractive {
            return deckAnimator?.interactiveTransitioner
        }
        return nil
    }
}


// MARK: - ExpressChatCoordinatorDelegate

extension TabCoordinator: ExpressChatCoordinatorDelegate {
    func expressChatCoordinatorDidSentMessages(_ coordinator: ExpressChatCoordinator, count: Int) {
        let message = count == 1 ? R.Strings.chatExpressOneMessageSentSuccessAlert :
            R.Strings.chatExpressSeveralMessagesSentSuccessAlert
        rootViewController.showAutoFadingOutMessageAlert(message: message)
    }
}


// MARK: - UserRatingCoordinatorDelegate 

extension TabCoordinator: UserRatingCoordinatorDelegate {
    func userRatingCoordinatorDidCancel() { }

    func userRatingCoordinatorDidFinish(withRating rating: Int?, ratedUserId: String?) { }
}


// MARK: - EditListingCoordinatorDelegate

extension TabCoordinator: EditListingCoordinatorDelegate {
    func editListingCoordinatorDidCancel(_ coordinator: EditListingCoordinator) {

    }
    
    func editListingCoordinator(_ coordinator: EditListingCoordinator,
                                didFinishWithListing listing: Listing,
                                bumpUpProductData: BumpUpProductData?,
                                timeSinceLastBump: TimeInterval?,
                                maxCountdown: TimeInterval) {
        guard let bumpData = bumpUpProductData,
            bumpData.hasPaymentId else { return }
        if let timeSinceLastBump = timeSinceLastBump,
            timeSinceLastBump > 0,
            featureFlags.bumpUpBoost.isActive {
            openBumpUpBoost(forListing: listing,
                            bumpUpProductData: bumpData,
                            typePage: .edit,
                            timeSinceLastBump: timeSinceLastBump,
                            maxCountdown: maxCountdown)
        } else {
            openPayBumpUp(forListing: listing,
                          bumpUpProductData: bumpData,
                          typePage: .edit,
                          maxCountdown: maxCountdown)
        }
    }
}

