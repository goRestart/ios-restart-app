import Foundation
import LGCoreKit
import LGComponents

final class ListingDetailWireframe: ListingDetailNavigator {
    private let nc: UINavigationController

    private let sessionManager: SessionManager
    private let featureFlags: FeatureFlaggeable

    private let bumpAssembly: BumpUpAssembly
    private let verificationAssembly: UserVerificationAssembly
    private let editAssembly: EditListingAssembly
    private let loginAssembly: LoginAssembly
    private let rateBuyerAssembly: RateBuyerAssembly

    private let chatNavigator: ChatNavigator

    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository

    private let bubbleManager: BubbleNotificationManager
    private let deeplinkMailBox: DeepLinkMailBox

    convenience init(nc: UINavigationController) {
        self.init(nc: nc,
                  sessionManager: Core.sessionManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  installationRepository: Core.installationRepository,
                  bumpAssembly: BumpUpBuilder.modal(nc),
                  verificationAssembly: LGUserVerificationBuilder.standard(nav: nc),
                  editAssembly: EditListingBuilder.modal(nc),
                  loginAssembly: LoginBuilder.modal,
                  rateBuyerAssembly: RateBuyerBuilder.modal(nc),
                  bubbleManager: LGBubbleNotificationManager.sharedInstance,
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance)

    }

    init(nc: UINavigationController,
         sessionManager: SessionManager,
         featureFlags: FeatureFlaggeable,
         myUserRepository: MyUserRepository,
         installationRepository: InstallationRepository,
         bumpAssembly: BumpUpAssembly,
         verificationAssembly: UserVerificationAssembly,
         editAssembly: EditListingAssembly,
         loginAssembly: LoginAssembly,
         rateBuyerAssembly: RateBuyerAssembly,
         bubbleManager: BubbleNotificationManager,
         deeplinkMailBox: DeepLinkMailBox) {
        self.nc = nc
        self.sessionManager = sessionManager
        self.featureFlags = featureFlags
        self.chatNavigator = ChatWireframe(nc: nc)
        self.installationRepository = installationRepository
        self.myUserRepository = myUserRepository
        self.bumpAssembly = bumpAssembly
        self.verificationAssembly = verificationAssembly
        self.editAssembly = editAssembly
        self.loginAssembly = loginAssembly
        self.rateBuyerAssembly = rateBuyerAssembly
        self.deeplinkMailBox = deeplinkMailBox
        self.bubbleManager = bubbleManager
    }

    func openAppRating(_ source: EventParameterRatingSource) {
        guard let url = URL.makeAppRatingDeeplink(with: source) else { return }
        deeplinkMailBox.push(convertible: url)
    }

    func openUserVerificationView() {
        let vc = verificationAssembly.buildUserVerification()
        nc.pushViewController(vc, animated: true)
    }

    func closeProductDetail() {
        nc.popViewController(animated: true)
    }

    func openUser(_ data: UserDetailData) {
        let userCoordinator = UserWireframe(nc: nc)
        userCoordinator.openUser(data)
    }

    func editListing(_ listing: Listing,
                     purchases: [BumpUpProductData],
                     listingCanBeBoosted: Bool,
                     timeSinceLastBump: TimeInterval?,
                     maxCountdown: TimeInterval) {
        let vc = editAssembly.buildEditView(listing: listing,
                                            pageType: nil,
                                            purchases: purchases,
                                            listingCanBeBoosted: listingCanBeBoosted,
                                            timeSinceLastBump: timeSinceLastBump,
                                            maxCountdown: maxCountdown,
                                            onEditAction: self)
                                            nc.present(vc, animated: true)
    }

    func openListingChat(_ listing: Listing, source: EventParameterTypePage, interlocutor: User?) {
        chatNavigator.openListingChat(listing, source: source, interlocutor: interlocutor, openChatAutomaticMessage: nil)
    }

    func closeListingAfterDelete(_ listing: Listing) {
        closeProductDetail()
        if (listing.status != .sold) && (listing.status != .soldOld) {
            let action = UIAction(interface: .button(R.Strings.productDeletePostButtonTitle,
                                                     .primary(fontSize: .medium)), action: { [weak self] in
                                                        guard let url = URL.makeSellDeeplink(with: .deleteListing,
                                                                                       category: nil,
                                                                                       title: nil) else { return }
                                                        self?.deeplinkMailBox.push(convertible: url)
                }, accessibility: AccessibilityId.postDeleteAlertButton)
            nc.showAlertWithTitle(R.Strings.productDeletePostTitle,
                                                     text: R.Strings.productDeletePostSubtitle,
                                                     alertType: .plainAlertOld, actions: [action])
        }
    }

    func openPayBumpUp(forListing listing: Listing,
                       purchases: [BumpUpProductData],
                       typePage: EventParameterTypePage?,
                       maxCountdown: TimeInterval) {
        let vc = bumpAssembly.buildPayBumpUp(forListing: listing,
                                             purchases: purchases,
                                             typePage: typePage,
                                             maxCountdown: maxCountdown)
        nc.present(vc, animated: true, completion: nil)
    }

    func openBumpUpBoost(forListing listing: Listing,
                         purchases: [BumpUpProductData],
                         typePage: EventParameterTypePage?,
                         timeSinceLastBump: TimeInterval,
                         maxCountdown: TimeInterval) {
        if timeSinceLastBump > 0 {
            let vc = bumpAssembly.buildBumpUpBoost(forListing: listing,
                                                   purchases: purchases,
                                                   typePage: typePage,
                                                   timeSinceLastBump: timeSinceLastBump,
                                                   maxCountdown: maxCountdown)
            nc.present(vc, animated: true, completion: nil)
        }
    }

    func openMultiDayBumpUp(forListing listing: Listing,
                            purchases: [BumpUpProductData],
                            typePage: EventParameterTypePage?,
                            maxCountdown: TimeInterval) {
        let vc = bumpAssembly.buildMultiDayBumpUp(forListing: listing,
                                                  purchases: purchases,
                                                  typePage: typePage,
                                                  maxCountdown: maxCountdown)
        nc.present(vc, animated: true, completion: nil)
    }

    func openMultiDayInfoBumpUp(forListing listing: Listing,
                                featurePurchaseType: FeaturePurchaseType,
                                typePage: EventParameterTypePage?,
                                timeSinceLastBump: TimeInterval,
                                maxCountdown: TimeInterval) {
        let vc = bumpAssembly.buildMultiDayInfoBumpUp(forListing: listing,
                                                  featurePurchaseType: featurePurchaseType,
                                                  typePage: typePage,
                                                  timeSinceLastBump: timeSinceLastBump,
                                                  maxCountdown: maxCountdown)
        nc.present(vc, animated: true, completion: nil)
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
                                                   onRateUserFinishAction: self)
        nc.present(vc, animated: true, completion: nil)
    }
    func showProductFavoriteBubble(with data: BubbleNotificationData) {
        bubbleManager.showBubble(data: data,
                                 duration: SharedConstants.bubbleFavoriteDuration,
                                 view: nc.view,
                                 alignment: .top(offset: nc.statusBarHeight),
                                 style: .light)
    }
    func openLoginIfNeededFromProductDetail(from: EventParameterLoginSourceValue,
                                            infoMessage: String,
                                            loggedInAction: @escaping (() -> Void)) {
        guard !sessionManager.loggedIn else {
            loggedInAction()
            return
        }

        let vc = loginAssembly.buildPopupSignUp(
            withMessage: R.Strings.productPostLoginMessage,
            andSource: from,
            appearance: .light,
            loginAction: loggedInAction,
            cancelAction: nil
        )
        vc.modalTransitionStyle = .crossDissolve
        nc.present(vc, animated: true)
    }

    func showBumpUpNotAvailableAlertWithTitle(title: String,
                                              text: String,
                                              alertType: AlertType,
                                              buttonsLayout: AlertButtonsLayout,
                                              actions: [UIAction]) {
        nc.showAlertWithTitle(title,
                                                 text: text,
                                                 alertType: alertType,
                                                 buttonsLayout: buttonsLayout,
                                                 actions: actions)
    }
    func showBumpUpBoostSucceededAlert() {
        let boostSuccessAlert = BoostSuccessAlertView()
        // the alert view has a thin blur that has to cover the nav bar too
        nc.view.addSubviewForAutoLayout(boostSuccessAlert)
        boostSuccessAlert.layout(with: nc.view).fill()
        boostSuccessAlert.alpha = 0
        nc.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            boostSuccessAlert.alpha = 1
            boostSuccessAlert.startAnimation()
        }
    }
    func openContactUs(forListing listing: Listing, contactUstype: ContactUsType) {
        guard let user = myUserRepository.myUser,
            let installation = installationRepository.installation,
            let contactURL = LetgoURLHelper.buildContactUsURL(user: user,
                                                              installation: installation,
                                                              listing: listing,
                                                              type: contactUstype) else {
                return
        }
        nc.openInAppWebViewWith(url: contactURL)
    }

    func openFeaturedInfo() {
        let assembly = FeaturedInfoBuilder.modal(nc)
        let vc = assembly.buildFeaturedInfo()
        nc.present(vc, animated: true, completion: nil)
    }

    func openAskPhoneFor(listing: Listing, interlocutor: User?) {
        let assembly = ProfessionalDealerAskPhoneBuilder.modal(nc)
        let vc = assembly.buildProfessionalDealerAskPhone(listing: listing,
                                                          interlocutor: interlocutor,
                                                          chatNavigator: chatNavigator)
        nc.present(vc, animated: true)
    }

    func openListingAttributeTable(withViewModel viewModel: ListingAttributeTableViewModel) {
        let viewController = ListingAttributeTableViewController(withViewModel: viewModel)
        nc.present(viewController, animated: true, completion: nil)
    }

    func closeListingAttributeTable() {
        nc.dismiss(animated: true, completion: nil)
    }

    func openPostAnotherListing() {
        let assembly = PostAnotherListingBuilder.modal(nc)
        let vc = assembly.buildPostAnotherListing()
        nc.present(vc, animated: true, completion: nil)
    }
}

extension ListingDetailWireframe: OnEditActionable {
    func onEdit(listing: Listing,
                purchases: [BumpUpProductData],
                timeSinceLastBump: TimeInterval?,
                maxCountdown: TimeInterval) {
        guard !purchases.isEmpty else { return }
        let allPurchasesHavePaymentId = !(purchases.filter { $0.hasPaymentId }.isEmpty)
        guard allPurchasesHavePaymentId else { return }
        if featureFlags.multiDayBumpUp.isActive {
            openMultiDayBumpUp(forListing: listing,
                               purchases: purchases,
                               typePage: .edit,
                               maxCountdown: maxCountdown)
        } else if let timeSinceLastBump = timeSinceLastBump, timeSinceLastBump > 0 {
            openBumpUpBoost(forListing: listing,
                            purchases: purchases,
                            typePage: .edit,
                            timeSinceLastBump: timeSinceLastBump,
                            maxCountdown: maxCountdown)
        } else {
            openPayBumpUp(forListing: listing,
                          purchases: purchases,
                          typePage: .edit,
                          maxCountdown: maxCountdown)
        }
    }
}

extension ListingDetailWireframe: OnRateUserFinishActionable {
    func onFinish() {
        openPostAnotherListing()
    }
}
