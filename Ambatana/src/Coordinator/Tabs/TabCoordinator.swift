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

    let listingRepository: ListingRepository
    let userRepository: UserRepository
    let chatRepository: ChatRepository
    let myUserRepository: MyUserRepository
    let installationRepository: InstallationRepository
    let keyValueStorage: KeyValueStorage
    let tracker: Tracker
    let featureFlags: FeatureFlaggeable
    let disposeBag = DisposeBag()

    weak var tabCoordinatorDelegate: TabCoordinatorDelegate?
    weak var appNavigator: AppNavigator?

    fileprivate var interactiveTransitioner: UIPercentDrivenInteractiveTransition?

    // MARK: - Lifecycle

    init(listingRepository: ListingRepository, userRepository: UserRepository, chatRepository: ChatRepository,
         myUserRepository: MyUserRepository, installationRepository: InstallationRepository,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage, tracker: Tracker, rootViewController: UIViewController,
         featureFlags: FeatureFlaggeable, sessionManager: SessionManager) {
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

    func openHome() {
        appNavigator?.openHome()
    }

    func openSell(source: PostingSource, postCategory: PostCategory?) {
        appNavigator?.openSell(source: source, postCategory: postCategory, listingTitle: nil)
    }

    func openAppRating(_ source: EventParameterRatingSource) {
        appNavigator?.openAppRating(source)
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
        switch data {
        case let .id(listingId):
            openListing(listingId: listingId, source: source, actionOnFirstAppear: actionOnFirstAppear)
        case let .listingAPI(listing, thumbnailImage, originFrame):
            openListing(listing: listing, thumbnailImage: thumbnailImage, originFrame: originFrame, source: source,
                        index: 0, discover: false, actionOnFirstAppear: actionOnFirstAppear)
        case let .listingList(listing, cellModels, requester, thumbnailImage, originFrame, showRelated, index):
            openListing(listing, cellModels: cellModels, requester: requester, thumbnailImage: thumbnailImage,
                        originFrame: originFrame, showRelated: showRelated, source: source,
                        index: index)
        case let .listingChat(chatConversation):
            openListing(chatConversation: chatConversation, source: source)
        }
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
    
    func openMostSearchedItems(source: PostingSource, enableSearch: Bool) {
        appNavigator?.openMostSearchedItems(source: source, enableSearch: enableSearch)
    }
    
    func openDeepLink(_ deeplink: DeepLink) {
        appNavigator?.openDeepLink(deepLink: deeplink)
    }

    func openUserVerificationView() {
        let vm = UserVerificationViewModel()
        vm.navigator = self
        let vc = UserVerificationViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    var hidesBottomBarWhenPushed: Bool {
        return navigationController.viewControllers.count == 1
    }
}

fileprivate extension TabCoordinator {
    func openListing(listingId: String, source: EventParameterListingVisitSource, actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        navigationController.showLoadingMessageAlert()
        listingRepository.retrieve(listingId) { [weak self] result in
            if let listing = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openListing(listing: listing, source: source, index: 0, discover: false,
                                      actionOnFirstAppear: actionOnFirstAppear)
                }
            } else if let error = result.error {
                switch error {
                case .network:
                    self?.navigationController.dismissLoadingMessageAlert {
                        self?.navigationController.showAutoFadingOutMessageAlert(message: R.Strings.commonErrorConnectionFailed)
                    }
                case .internalError, .unauthorized, .tooManyRequests, .userNotVerified, .serverError,
                     .wsChatError, .searchAlertError:
                    self?.navigationController.dismissLoadingMessageAlert {
                        self?.navigationController.showAutoFadingOutMessageAlert(message: R.Strings.commonProductNotAvailable)
                    }
                case .notFound, .forbidden:
                    let relatedRequester = RelatedListingListRequester(listingId: listingId,
                                                                       itemsPerPage: SharedConstants.numListingsPerPageDefault)
                    relatedRequester.retrieveFirstPage { result in
                        self?.navigationController.dismissLoadingMessageAlert {
                            if let relatedListings = result.listingsResult.value, !relatedListings.isEmpty {
                                self?.openRelatedListingsForNonExistentListing(listingId: listingId,
                                                                               source: source,
                                                                               requester: relatedRequester,
                                                                               relatedListings: relatedListings)
                            }
                            self?.navigationController.showAutoFadingOutMessageAlert(message: R.Strings.commonProductNotAvailable)
                        }
                    }
                }
                self?.trackProductNotAvailable(source: source, repositoryError: error)
            }
        }
    }

    func openListing(listing: Listing, thumbnailImage: UIImage? = nil, originFrame: CGRect? = nil,
                             source: EventParameterListingVisitSource, requester: ListingListRequester? = nil, index: Int,
                             discover: Bool, actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        guard let listingId = listing.objectId else { return }
        var requestersArray: [ListingListRequester] = []
        let listingListRequester: ListingListRequester?
        if discover {
            listingListRequester = DiscoverListingListRequester(listingId: listingId,
                                                                itemsPerPage: SharedConstants.numListingsPerPageDefault)
        } else {
            listingListRequester = RelatedListingListRequester(listing: listing,
                                                               itemsPerPage: SharedConstants.numListingsPerPageDefault)
        }
        guard let relatedRequester = listingListRequester else { return }
        requestersArray.append(relatedRequester)

        // Adding product list after related
        let listOffset = index + 1 // we need the product AFTER the current one
        if let requester = requester {
            let requesterCopy = requester.duplicate()
            requesterCopy.updateInitialOffset(listOffset)
            requestersArray.append(requesterCopy)
        } else {
            let filteredRequester = FilteredListingListRequester(itemsPerPage: SharedConstants.numListingsPerPageDefault, offset: listOffset)
            requestersArray.append(filteredRequester)
        }

        let requester = ListingListMultiRequester(requesters: requestersArray)
        if featureFlags.deckItemPage.isActive {
            openListingNewItemPage(listing,
                                   thumbnailImage: thumbnailImage,
                                   cellModels: nil,
                                   originFrame: nil,
                                   requester: requester,
                                   source: source,
                                   actionOnFirstAppear: actionOnFirstAppear,
                                   trackingIndex: nil)
        } else {
            let vm = ListingCarouselViewModel(listing: listing, thumbnailImage: thumbnailImage,
                                              listingListRequester: requester, source: source,
                                              actionOnFirstAppear: actionOnFirstAppear, trackingIndex: index)
            vm.navigator = self
            openListing(vm, thumbnailImage: thumbnailImage, originFrame: originFrame, listingId: listingId)
        }

    }

    func openListing(_ listing: Listing, cellModels: [ListingCellModel], requester: ListingListRequester,
                     thumbnailImage: UIImage?, originFrame: CGRect?, showRelated: Bool,
                     source: EventParameterListingVisitSource, index: Int) {
        if showRelated {
            //Same as single product opening
            openListing(listing: listing,
                        thumbnailImage: thumbnailImage,
                        originFrame: originFrame,
                        source: source,
                        requester: requester,
                        index: index,
                        discover: false,
                        actionOnFirstAppear: .nonexistent)
        } else if featureFlags.deckItemPage.isActive {
            openListingNewItemPage(listing,
                                   thumbnailImage: thumbnailImage,
                                   cellModels: cellModels,
                                   originFrame: originFrame,
                                   requester: requester,
                                   source: source,
                                   actionOnFirstAppear: .nonexistent,
                                   trackingIndex: index)
        } else {
            let vm = ListingCarouselViewModel(productListModels: cellModels, initialListing: listing,
                                              thumbnailImage: thumbnailImage, listingListRequester: requester, source: source,
                                              actionOnFirstAppear: .nonexistent, trackingIndex: index,
                                              firstProductSyncRequired: false)
            vm.navigator = self
            openListing(vm, thumbnailImage: thumbnailImage, originFrame: originFrame, listingId: listing.objectId)
        }
    }

    func openListing(chatConversation: ChatConversation, source: EventParameterListingVisitSource) {
        guard let localProduct = LocalProduct(chatConversation: chatConversation, myUser: myUserRepository.myUser),
            let listingId = localProduct.objectId else { return }
        let relatedRequester = RelatedListingListRequester(listingId: listingId,
                                                           itemsPerPage: SharedConstants.numListingsPerPageDefault)
        let filteredRequester = FilteredListingListRequester( itemsPerPage: SharedConstants.numListingsPerPageDefault, offset: 0)
        let requester = ListingListMultiRequester(requesters: [relatedRequester, filteredRequester])

        if featureFlags.deckItemPage.isActive {
            openListingNewItemPage(listing: .product(localProduct),
                                   listingListRequester: requester,
                                   source: source)
        } else {
            let vm = ListingCarouselViewModel(listing: .product(localProduct), listingListRequester: requester,
                                              source: source, actionOnFirstAppear: .nonexistent, trackingIndex: nil)
            vm.navigator = self
            openListing(vm, thumbnailImage: nil, originFrame: nil, listingId: listingId)
        }
    }

    func openListing(_ viewModel: ListingCarouselViewModel, thumbnailImage: UIImage?, originFrame: CGRect?,
                     listingId: String?) {
        let color = UIColor.placeholderBackgroundColor(listingId)
        let animator = ListingCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage,
                                                   backgroundColor: color)
        let vc = ListingCarouselViewController(viewModel: viewModel, pushAnimator: animator)
        navigationController.pushViewController(vc, animated: true)
    }

    func openListingNewItemPage(listing: Listing,
                                listingListRequester: ListingListRequester,
                                source: EventParameterListingVisitSource) {
        openListingNewItemPage(listing,
                               thumbnailImage: nil,
                               cellModels: nil,
                               originFrame: nil,
                               requester: listingListRequester,
                               source: source,
                               actionOnFirstAppear: .nonexistent,
                               trackingIndex: nil)
    }

    func openListingNewItemPage(_ listing: Listing,
                                thumbnailImage: UIImage?,
                                cellModels: [ListingCellModel]?,
                                originFrame: CGRect?,
                                requester: ListingListRequester,
                                source: EventParameterListingVisitSource,
                                actionOnFirstAppear: DeckActionOnFirstAppear,
                                trackingIndex: Int?) {
        if deckAnimator == nil {
            let coordinator = DeckCoordinator(withNavigationController: navigationController)
            deckAnimator = coordinator
        }

        let viewModel = ListingDeckViewModel(listModels: cellModels ?? [],
                                             listing: listing,
                                             listingListRequester: requester,
                                             source: source,
                                             detailNavigator: self,
                                             actionOnFirstAppear: actionOnFirstAppear,
                                             trackingIndex: trackingIndex)

        let deckViewController = ListingDeckViewController(viewModel: viewModel)
        viewModel.delegate = deckViewController
        viewModel.navigator = self

        deckAnimator?.setupWith(viewModel: viewModel)
        navigationController.pushViewController(deckViewController, animated: true)
    }

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

    func openUser(user: User, source: UserSource) {
        // If it's me do not then open the user profile
        guard myUserRepository.myUser?.objectId != user.objectId else { return }

        let vm = UserProfileViewModel.makePublicProfile(user: user, source: source)
        vm.navigator = self
        let vc = UserProfileViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
    }

    func openUser(_ interlocutor: ChatInterlocutor) {
        let vm = UserProfileViewModel.makePublicProfile(chatInterlocutor: interlocutor, source: .chat)
        vm.navigator = self
        let vc = UserProfileViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
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


    func openRelatedListingsForNonExistentListing(listingId: String,
                                                          source: EventParameterListingVisitSource,
                                                          requester: ListingListRequester,
                                                          relatedListings: [Listing]) {
        let simpleRelatedListingsVM = SimpleListingsViewModel(requester: requester,
                                                              listings: relatedListings,
                                                              title: R.Strings.relatedItemsTitle,
                                                              listingVisitSource: .relatedListings)
        simpleRelatedListingsVM.navigator = self
        let simpleRelatedListingsVC = SimpleListingsViewController(viewModel: simpleRelatedListingsVM)
        navigationController.pushViewController(simpleRelatedListingsVC, animated: true)
        
        trackRelatedListings(listingId: listingId,
                             source: .notFound)
    }
}

extension TabCoordinator: UserVerificationNavigator {
    func closeUserVerification() {
        navigationController.popViewController(animated: true)
    }

    func openEmailVerification() {
        let vm = UserVerificationEmailViewModel()
        vm.navigator = self
        let vc = UserVerificationEmailViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openEditUserBio() {
        let vm = EditUserBioViewModel()
        vm.navigator = self
        let vc = EditUserBioViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openPhoneNumberVerification() {
        let vm = UserPhoneVerificationNumberInputViewModel()
        vm.navigator = self
        let vc = UserPhoneVerificationNumberInputViewController(viewModel: vm)
        vm.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }
}

extension TabCoordinator: EditUserBioNavigator {
    func closeEditUserBio() {
        navigationController.popViewController(animated: true)
    }
}

extension TabCoordinator: VerifyUserEmailNavigator {
    func closeEmailVerification() {
        navigationController.popViewController(animated: true)
    }
}

extension TabCoordinator: UserPhoneVerificationNavigator {
    func openCountrySelector(withDelegate delegate: UserPhoneVerificationCountryPickerDelegate) {
        let vm = UserPhoneVerificationCountryPickerViewModel()
        vm.navigator = self
        vm.delegate = delegate
        let vc = UserPhoneVerificationCountryPickerViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func closeCountrySelector() {
        navigationController.popViewController(animated: true)
    }

    func openCodeInput(sentTo phoneNumber: String, with callingCode: String) {
        let vm = UserPhoneVerificationCodeInputViewModel(callingCode: callingCode,
                                                         phoneNumber: phoneNumber)
        vm.navigator = self
        let vc = UserPhoneVerificationCodeInputViewController(viewModel: vm)
        vm.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }

    func closePhoneVerificaction() {
        guard let vc = navigationController.viewControllers
            .filter({ $0 is UserVerificationViewController }).first else { return }
        navigationController.popToViewController(vc, animated: true)
    }
}

// MARK: > ListingDetailNavigator

extension TabCoordinator: ListingDetailNavigator {
    
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
                }, accessibilityId: .postDeleteAlertButton)
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
        let askNumVM = ProfessionalDealerAskPhoneViewModel(listing: listing, interlocutor: interlocutor)
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
    
    func openRealEstateOnboarding(pages: [LGTutorialPage],
                                  origin: EventParameterTypePage,
                                  tutorialType: EventParameterTutorialType) {
        guard pages.count > 0 else { return }
        let viewModel = LGTutorialViewModel(pages: pages, origin: origin, tutorialType: tutorialType)
        let viewController = LGTutorialViewController(viewModel: viewModel)
        navigationController.present(viewController, animated: true, completion: nil)
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
}


// MARK: SimpleProductsNavigator

extension TabCoordinator: SimpleProductsNavigator {
    func closeSimpleProducts() {
        navigationController.popViewController(animated: true)
    }
}


// MARK: > ChatDetailNavigator

extension TabCoordinator: ChatDetailNavigator {
    func closeChatDetail() {
        navigationController.popViewController(animated: true)
    }
    
    func openDeeplink(url: URL) {
        guard let deepLink = UriScheme.buildFromUrl(url)?.deepLink else { return }
        openDeepLink(deepLink)
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


// MARK: - Tracking

extension TabCoordinator {
    func trackProductNotAvailable(source: EventParameterListingVisitSource, repositoryError: RepositoryError) {
        var reason: EventParameterNotAvailableReason
        switch repositoryError {
        case .internalError, .wsChatError, .searchAlertError:
            reason = .internalError
        case .notFound:
            reason = .notFound
        case .unauthorized:
            reason = .unauthorized
        case .forbidden:
            reason = .forbidden
        case .tooManyRequests:
            reason = .tooManyRequests
        case .userNotVerified:
            reason = .userNotVerified
        case .serverError:
            reason = .serverError
        case .network:
            reason = .network
        }
        let productNotAvailableEvent = TrackerEvent.listingNotAvailable( source, reason: reason)
        tracker.trackEvent(productNotAvailableEvent)
    }
    
    func trackRelatedListings(listingId: String,
                              source: EventParameterRelatedListingsVisitSource) {
        let relatedListings = TrackerEvent.relatedListings(listingId: listingId,
                                                           source: source)
        tracker.trackEvent(relatedListings)
    }
}

