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

    lazy var listingNavigator = ListingWireframe(nc: navigationController)
    lazy var userNavigator = UserWireframe(nc: navigationController)
    lazy var chatNavigator = ChatWireframe(nc: navigationController)

    var deckAnimator: DeckAnimator?

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

    private lazy var verificationAssembly = LGUserVerificationBuilder.standard(nav: navigationController)
    private lazy var rateBuyerAssembly = RateBuyerBuilder.modal(navigationController)
    private lazy var expressChatAssembly = ExpressChatBuilder.modal(navigationController)

    weak var tabCoordinatorDelegate: TabCoordinatorDelegate?
    weak var appNavigator: AppNavigator?

    fileprivate var interactiveTransitioner: UIPercentDrivenInteractiveTransition?

    // MARK: - Lifecycle

    init(listingRepository: ListingRepository, userRepository: UserRepository, chatRepository: ChatRepository,
         myUserRepository: MyUserRepository, installationRepository: InstallationRepository,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage, tracker: Tracker, rootViewController: UIViewController,
         featureFlags: FeatureFlaggeable, sessionManager: SessionManager, deeplinkMailBox: DeepLinkMailBox,
         externalNC: UINavigationController? = nil) {
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
        if let nc = externalNC {
            self.navigationController = nc
        } else {
            self.navigationController = UINavigationController(rootViewController: rootViewController)
        }
        self.deeplinkMailBox = deeplinkMailBox

        super.init()

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
        appNavigator?.showBottomBubbleNotification(data: data,
                                                   duration: duration,
                                                   alignment: .bottomTabBar,
                                                   style: .light)
    }

    func showFailBubble(withMessage message: String, duration: TimeInterval) {
        let data = BubbleNotificationData(text: message, action: nil)
        appNavigator?.showBottomBubbleNotification(data: data,
                                                   duration: duration,
                                                   alignment: .bottomTabBar,
                                                   style: .dark)
    }

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
        listingNavigator.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }

    func openChat(_ data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?) {
        chatNavigator.openChat(data, source: source, predefinedMessage: predefinedMessage)
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
        userNavigator.openUser(user: user, source: source, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
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
        userNavigator.openUser(interlocutor, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
    }
}
extension TabCoordinator: ChatInactiveConversationsListNavigator {}

extension TabCoordinator {
    func openEditUserBio() {
        let router = UserVerificationWireframe(nc: navigationController)
        router.openEditUserBio()
    }
}

// MARK: > ChatDetailNavigator

extension TabCoordinator: ChatDetailNavigator {
    func openAppRating(_ source: EventParameterRatingSource) {
        guard let url = URL.makeAppRatingDeeplink(with: source) else { return }
        deeplinkMailBox.push(convertible: url)
    }

    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo) {
        let vc = rateBuyerAssembly.buildRateBuyers(source: source,
                                                   buyers: buyers,
                                                   listingId: listingId,
                                                   sourceRateBuyers: sourceRateBuyers,
                                                   trackingInfo: trackingInfo,
                                                   onRateUserFinishAction: nil)
        navigationController.present(vc, animated: true, completion: nil)
    }

    func navigate(with convertible: DeepLinkConvertible) {
        deeplinkMailBox.push(convertible: convertible)
    }

    func closeChatDetail() {
        navigationController.popViewController(animated: true)
    }

    func openExpressChat(_ listings: [Listing], sourceListingId: String, manualOpen: Bool) {
        let vc = expressChatAssembly.buildExpressChat(listings: listings,
                                                      sourceProductId: sourceListingId,
                                                      manualOpen: manualOpen)
        navigationController.present(vc, animated: true, completion: nil)
    }

    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue,
                                         loggedInAction: @escaping (() -> Void)) {
        guard !sessionManager.loggedIn else {
            loggedInAction()
            return
        }
        let vc = LoginBuilder.modal.buildPopupSignUp(
            withMessage: R.Strings.chatLoginPopupText,
            andSource: from, loginAction: loggedInAction, cancelAction: nil)
        viewController.present(vc, animated: true, completion: nil)
    }

    func openAssistantFor(listingId: String, dataDelegate: MeetingAssistantDataDelegate) {
        let assembly = AssistantMeetingBuilder.modal(navigationController)
        let vc = assembly.buildAssistantFor(listingId: listingId, dataDelegate: dataDelegate)
        navigationController.present(vc, animated: true, completion: nil)
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
