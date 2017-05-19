//
//  ProductViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift


protocol ProductViewModelDelegate: class, BaseViewModelDelegate {

    func vmOpenCommercialDisplay(_ displayVM: CommercialDisplayViewModel)
    func vmShowProductDetailOptions(_ cancelLabel: String, actions: [UIAction])

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?)

    // Bump Up
    func vmResetBumpUpBannerCountdown()
}

protocol ProductViewModelMaker {
    func make(listing: Listing, visitSource: EventParameterProductVisitSource) -> ProductViewModel
}

class ProductViewModel: BaseViewModel {
    class ConvenienceMaker: ProductViewModelMaker {
        func make(listing: Listing, visitSource source: EventParameterProductVisitSource) -> ProductViewModel {
            return ProductViewModel(listing: listing,
                                    visitSource: source,
                                     myUserRepository: Core.myUserRepository,
                                     listingRepository: Core.listingRepository,
                                     commercializerRepository: Core.commercializerRepository,
                                     chatWrapper: LGChatWrapper(),
                                     chatViewMessageAdapter: ChatViewMessageAdapter(),
                                     locationManager: Core.locationManager,
                                     countryHelper: Core.countryHelper,
                                     socialSharer: SocialSharer(),
                                     featureFlags: FeatureFlags.sharedInstance,
                                     purchasesShopper: LGPurchasesShopper.sharedInstance,
                                     monetizationRepository: Core.monetizationRepository,
                                     tracker: TrackerProxy.sharedInstance)
        }
    }

    // Delegate
    weak var delegate: ProductViewModelDelegate?
    weak var navigator: ProductDetailNavigator?

    // Data
    let listing: Variable<Listing>
    var isMine: Bool {
        return listing.value.isMine(myUserRepository: myUserRepository)
    }
    let isFavorite = Variable<Bool>(false)
    let listingStats = Variable<ListingStats?>(nil)

    let socialMessage = Variable<SocialMessage?>(nil)
    let socialSharer: SocialSharer
    fileprivate var freeBumpUpShareMessage: SocialMessage?

    let directChatMessages = CollectionVariable<ChatViewMessage>([])
    var quickAnswers: [QuickAnswer] {
        guard !isMine else { return [] }
        let isFree = listing.value.price.free && featureFlags.freePostingModeAllowed
        return QuickAnswer.quickAnswersForPeriscope(isFree: isFree, repeatingPlaceholderText: featureFlags.quickAnswersRepeatedTextField)
    }

    let navBarButtons = Variable<[UIAction]>([])
    let actionButtons = Variable<[UIAction]>([])
    let directChatEnabled = Variable<Bool>(false)
    var directChatPlaceholder: String {
        let userName = listing.value.user.name?.toNameReduced(maxChars: Constants.maxCharactersOnUserNameChatButton) ?? ""
        return LGLocalizedString.productChatWithSellerNameButton(userName)
    }
    fileprivate let productIsFavoriteable = Variable<Bool>(false)
    let favoriteButtonState = Variable<ButtonState>(.enabled)
    let shareButtonState = Variable<ButtonState>(.hidden)

    let productInfo = Variable<ProductVMProductInfo?>(nil)
    let productImageURLs = Variable<[URL]>([])
    let userInfo: Variable<ProductVMUserInfo>

    let status = Variable<ProductViewModelStatus>(.pending)

    fileprivate let commercializers: Variable<[Commercializer]?>
    fileprivate let isReported = Variable<Bool>(false)
    fileprivate let productHasReadyCommercials = Variable<Bool>(false)

    let bumpUpBannerInfo = Variable<BumpUpInfo?>(nil)
    fileprivate var timeSinceLastBump: TimeInterval = 0
    fileprivate var bumpUpPurchaseableProduct: PurchaseableProduct?
    fileprivate var isUpdatingBumpUpBanner: Bool = false
    fileprivate var paymentItemId: String?

    fileprivate var alreadyTrackedFirstMessageSent: Bool = false
    fileprivate static let bubbleTagGroup = "favorite.bubble.group"

    // UI - Input
    let moreInfoState = Variable<MoreInfoState>(.hidden)

    // Repository, helpers & tracker
    let trackHelper: ProductVMTrackHelper

    fileprivate let myUserRepository: MyUserRepository
    fileprivate let listingRepository: ListingRepository
    fileprivate let commercializerRepository: CommercializerRepository
    fileprivate let chatWrapper: ChatWrapper
    fileprivate let countryHelper: CountryHelper
    fileprivate let locationManager: LocationManager
    fileprivate let chatViewMessageAdapter: ChatViewMessageAdapter
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let purchasesShopper: PurchasesShopper
    fileprivate let monetizationRepository: MonetizationRepository
    fileprivate let showFeaturedStripeHelper: ShowFeaturedStripeHelper
    fileprivate let visitSource: EventParameterProductVisitSource
    
    let isShowingFeaturedStripe = Variable<Bool>(false)

    // Retrieval status
    private var relationRetrieved = false
    private var commercialsRetrieved: Bool {
        return commercializers.value != nil
    }

    // Rx
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    init(listing: Listing,
         visitSource: EventParameterProductVisitSource,
         myUserRepository: MyUserRepository,
         listingRepository: ListingRepository,
         commercializerRepository: CommercializerRepository,
         chatWrapper: ChatWrapper,
         chatViewMessageAdapter: ChatViewMessageAdapter,
         locationManager: LocationManager,
         countryHelper: CountryHelper,
         socialSharer: SocialSharer,
         featureFlags: FeatureFlaggeable,
         purchasesShopper: PurchasesShopper,
         monetizationRepository: MonetizationRepository,
         tracker: Tracker) {
        self.listing = Variable<Listing>(listing)
        self.visitSource = visitSource
        self.socialSharer = socialSharer
        self.myUserRepository = myUserRepository
        self.listingRepository = listingRepository
        self.countryHelper = countryHelper
        self.trackHelper = ProductVMTrackHelper(tracker: tracker, listing: listing, featureFlags: featureFlags)
        self.commercializerRepository = commercializerRepository
        self.commercializers = Variable<[Commercializer]?>(nil)
        self.chatWrapper = chatWrapper
        self.locationManager = locationManager
        self.chatViewMessageAdapter = chatViewMessageAdapter
        self.featureFlags = featureFlags
        self.purchasesShopper = purchasesShopper
        self.monetizationRepository = monetizationRepository
        self.showFeaturedStripeHelper = ShowFeaturedStripeHelper(featureFlags: featureFlags, myUserRepository: myUserRepository)
        self.userInfo = Variable<ProductVMUserInfo>(ProductVMUserInfo(userListing: listing.user, myUser: myUserRepository.myUser))
        self.disposeBag = DisposeBag()

        super.init()

        socialSharer.delegate = self
        setupRxBindings()
    }
    
    internal override func didBecomeActive(_ firstTime: Bool) {
        guard let listingId = listing.value.objectId else { return }
        listingRepository.incrementViews(listingId: listingId, visitSource: visitSource.rawValue, completion: nil)

        if !relationRetrieved && myUserRepository.myUser != nil {
            listingRepository.retrieveUserListingRelation(listingId) { [weak self] result in
                guard let value = result.value  else { return }
                self?.relationRetrieved = true
                self?.isFavorite.value = value.isFavorited
                self?.isReported.value = value.isReported
            }
        }

        if listingStats.value == nil {
            listingRepository.retrieveStats(listingId: listingId) { [weak self] result in
                guard let stats = result.value else { return }
                self?.listingStats.value = stats
            }
        }

        if !commercialsRetrieved && featureFlags.commercialsAllowedFor(productCountryCode: listing.value.postalAddress.countryCode) {
            commercializerRepository.index(listingId) { [weak self] result in
                guard let value = result.value else { return }
                let readyCommercials = value.filter {$0.status == .ready }
                self?.productHasReadyCommercials.value = !readyCommercials.isEmpty
                self?.commercializers.value = value
            }
        }

        purchasesShopper.delegate = self

        if bumpUpBannerInfo.value == nil {
            refreshBumpeableBanner()
        }
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        bumpUpBannerInfo.value = nil
    }

    func syncListing(_ completion: (() -> ())?) {
        guard let listingId = listing.value.objectId else { return }
        listingRepository.retrieve(listingId) { [weak self] result in
            if let listing = result.value {
                self?.listing.value = listing
            }
            completion?()
        }
    }

    private func setupRxBindings() {

        if let productId = listing.value.objectId {
            listingRepository.updateEvents(for: productId).bindNext { [weak self] listing in
                self?.listing.value = listing
            }.addDisposableTo(disposeBag)
        }

        status.asObservable().bindNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.refreshActionButtons(status)
            strongSelf.refreshNavBarButtons()
            strongSelf.directChatEnabled.value = status.directChatsAvailable
        }.addDisposableTo(disposeBag)

        // bumpeable listing check
        status.asObservable().bindNext { [weak self] status in
            if status.isBumpeable {
                self?.refreshBumpeableBanner()
            } else {
                self?.bumpUpBannerInfo.value = nil
            }
        }.addDisposableTo(disposeBag)

        isFavorite.asObservable().subscribeNext { [weak self] _ in
            self?.refreshNavBarButtons()
        }.addDisposableTo(disposeBag)

        listing.asObservable().subscribeNext { [weak self] listing in
            guard let strongSelf = self else { return }
            strongSelf.trackHelper.listing = listing
            let isMine = listing.isMine(myUserRepository: strongSelf.myUserRepository)
            strongSelf.status.value = ProductViewModelStatus(listing: listing, isMine: isMine, featureFlags: strongSelf.featureFlags)

            strongSelf.isShowingFeaturedStripe.value = strongSelf.showFeaturedStripeHelper.shouldShowFeaturedStripeFor(listing: listing) && !strongSelf.status.value.shouldShowStatus

            strongSelf.productIsFavoriteable.value = !isMine
            strongSelf.isFavorite.value = listing.favorite
            strongSelf.socialMessage.value = ProductSocialMessage(listing: listing, fallbackToStore: false)
            strongSelf.freeBumpUpShareMessage = ProductSocialMessage(listing: listing, fallbackToStore: true)
            strongSelf.productImageURLs.value = listing.images.flatMap { return $0.fileURL }

            let productInfo = ProductVMProductInfo(listing: listing,
                                                   isAutoTranslated: listing.isTitleAutoTranslated(strongSelf.countryHelper),
                                                   distance: strongSelf.distanceString(listing))
            strongSelf.productInfo.value = productInfo

        }.addDisposableTo(disposeBag)

        status.asObservable().bindNext { [weak self] status in
            guard let isMine = self?.isMine else { return }
            self?.shareButtonState.value = isMine ? .enabled : .hidden
        }.addDisposableTo(disposeBag)

        myUserRepository.rx_myUser.bindNext { [weak self] _ in
            self?.refreshStatus()
        }.addDisposableTo(disposeBag)

        productIsFavoriteable.asObservable().bindNext { [weak self] favoriteable in
            self?.favoriteButtonState.value = favoriteable ? .enabled : .hidden
        }.addDisposableTo(disposeBag)

        moreInfoState.asObservable().map { (state: MoreInfoState) in
            return state == .shown
        }.distinctUntilChanged().bindNext { [weak self] shown in
            self?.refreshNavBarButtons()
        }.addDisposableTo(disposeBag)
    }
    
    private func distanceString(_ listing: Listing) -> String? {
        guard let userLocation = locationManager.currentLocation?.location else { return nil }
        let distance = listing.location.distanceTo(userLocation)
        let distanceString = String(format: "%0.1f %@", arguments: [distance, DistanceType.systemDistanceType().string])
        return LGLocalizedString.productDistanceXFromYou(distanceString)
    }

    private func refreshStatus() {
        status.value = ProductViewModelStatus(listing: listing.value, isMine: isMine, featureFlags: featureFlags)
    }

    func refreshBumpeableBanner() {
        guard let listingId = listing.value.objectId, status.value.isBumpeable, !isUpdatingBumpUpBanner,
                (featureFlags.freeBumpUpEnabled || featureFlags.pricedBumpUpEnabled) else { return }

        let isBumpUpPending = purchasesShopper.isBumpUpPending(forListingId: listingId)

        if isBumpUpPending {
            createBumpeableBanner(forListingId: listingId, withPrice: nil, paymentItemId: nil, bumpUpType: .restore)
        } else {
            isUpdatingBumpUpBanner = true
            monetizationRepository.retrieveBumpeableProductInfo(productId: listingId, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.isUpdatingBumpUpBanner = false
                guard let bumpeableProduct = result.value else { return }

                strongSelf.timeSinceLastBump = bumpeableProduct.timeSinceLastBump
                let freeItems = bumpeableProduct.paymentItems.filter { $0.provider == .letgo }
                let paymentItems = bumpeableProduct.paymentItems.filter { $0.provider == .apple }
                if !paymentItems.isEmpty, strongSelf.featureFlags.pricedBumpUpEnabled {
                    // will be considered bumpeable ONCE WE GOT THE PRICES of the products, not before.
                    strongSelf.paymentItemId = paymentItems.first?.itemId
                    // if "paymentItemId" is nil, the banner creation will fail, so we check this here to avoid
                    // a useless request to apple
                    if let _ = strongSelf.paymentItemId {
                        strongSelf.purchasesShopper.productsRequestStartForProduct(listingId, withIds: paymentItems.map { $0.providerItemId })
                    }
                } else if !freeItems.isEmpty, strongSelf.featureFlags.freeBumpUpEnabled {
                    strongSelf.paymentItemId = freeItems.first?.itemId
                    strongSelf.createBumpeableBanner(forListingId: listingId, withPrice: nil,
                                                        paymentItemId: strongSelf.paymentItemId, bumpUpType: .free)
                }
            })
        }
    }

    fileprivate func createBumpeableBanner(forListingId listingId: String, withPrice: String?, paymentItemId: String?, bumpUpType: BumpUpType) {

        var primaryBlock: () -> Void
        var buttonBlock: () -> Void
        switch bumpUpType {
        case .free:
            guard let paymentItemId = paymentItemId else { return }
            let freeBlock = { [weak self] in
                guard let listing = self?.listing.value, let socialMessage = self?.freeBumpUpShareMessage else { return }
                self?.trackBumpUpStarted(.free)
                self?.navigator?.openFreeBumpUp(forListing: listing, socialMessage: socialMessage,
                                                paymentItemId: paymentItemId)
            }
            primaryBlock = freeBlock
            buttonBlock = freeBlock
        case .priced:
            guard let paymentItemId = paymentItemId else { return }
            primaryBlock = { [weak self] in
                guard let listing = self?.listing.value else { return }
                guard let purchaseableProduct = self?.bumpUpPurchaseableProduct else { return }
                self?.navigator?.openPayBumpUp(forListing: listing, purchaseableProduct: purchaseableProduct,
                                               paymentItemId: paymentItemId)
            }
            buttonBlock = { [weak self] in
                self?.bumpUpProduct(productId: listingId)
            }
        case .restore:
            let restoreBlock = { [weak self] in
                logMessage(.info, type: [.monetization], message: "TRY TO Restore Bump for listing: \(listingId)")
                self?.purchasesShopper.requestPricedBumpUp(forListingId: listingId)
            }
            primaryBlock = restoreBlock
            buttonBlock = restoreBlock
        }

        bumpUpBannerInfo.value = BumpUpInfo(type: bumpUpType, timeSinceLastBump: timeSinceLastBump, price: withPrice,
                                      primaryBlock: primaryBlock, buttonBlock: buttonBlock)
    }
}


// MARK: - Public actions

extension ProductViewModel {

    func openProductOwnerProfile() {
        let data = UserDetailData.userAPI(user: LocalUser(userListing: listing.value.user), source: .productDetail)
        navigator?.openUser(data)
    }

    func editListing() {
        navigator?.editListing(listing.value)
    }

    func shareProduct() {
        guard let socialMessage = socialMessage.value else { return }
        guard let viewController = delegate?.vmShareViewControllerAndItem().0 else { return }
        let barButtonItem = delegate?.vmShareViewControllerAndItem().1
        socialSharer.share(socialMessage, shareType: .native(restricted: false),
                           viewController: viewController, barButtonItem: barButtonItem)
    }

    func chatWithSeller() {
        let source: EventParameterTypePage = (moreInfoState.value == .shown) ? .productDetailMoreInfo : .productDetail
        trackHelper.trackChatWithSeller(source)
        navigator?.openListingChat(listing.value)
    }

    func sendDirectMessage(_ text: String, isDefaultText: Bool) {
        ifLoggedInRunActionElseOpenSignUp(from: .directChat, infoMessage: LGLocalizedString.chatLoginPopupText) { [weak self] in
            if isDefaultText {
                self?.sendMessage(type: .periscopeDirect(text))
            } else {
                self?.sendMessage(type: .text(text))
            }
        }
    }

    func sendQuickAnswer(quickAnswer: QuickAnswer) {
        ifLoggedInRunActionElseOpenSignUp(from: .directQuickAnswer, infoMessage: LGLocalizedString.chatLoginPopupText) { [weak self] in
            self?.sendMessage(type: .quickAnswer(quickAnswer))
        }
    }

    func openVideo() {
        guard let commercializers = commercializers.value else { return }

        let readyCommercializers = commercializers.filter {$0.status == .ready }

        guard let commercialDisplayVM = CommercialDisplayViewModel(commercializers: readyCommercializers,
                                                                   productId: listing.value.objectId,
                                                                   source: .productDetail,
                                                                   isMyVideo: isMine) else { return }
        delegate?.vmOpenCommercialDisplay(commercialDisplayVM)
    }

    func switchFavorite() {
        ifLoggedInRunActionElseOpenSignUp(from: .favourite, infoMessage: LGLocalizedString.productFavoriteLoginPopupText) {
            [weak self] in self?.switchFavoriteAction()
        }
    }

    func bumpUpProduct(productId: String) {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump with purchase: \(bumpUpPurchaseableProduct)")
        guard let purchaseableProduct = bumpUpPurchaseableProduct,
            let paymentItemId = paymentItemId else { return }
        purchasesShopper.requestPayment(forListingId: productId, appstoreProduct: purchaseableProduct,
                                                  paymentItemId: paymentItemId)
    }

    func titleURLPressed(_ url: URL) {
        showItemHiddenIfNeededFor(url: url)
    }

    func descriptionURLPressed(_ url: URL) {
        showItemHiddenIfNeededFor(url: url)
    }
}


// MARK: - Helper Navbar

extension ProductViewModel {

    fileprivate func refreshNavBarButtons() {
        navBarButtons.value = buildNavBarButtons()
    }

    private func buildNavBarButtons() -> [UIAction] {
        var navBarButtons = [UIAction]()

        if isMine {
            if status.value.isEditable {
                navBarButtons.append(buildEditNavBarAction())
            }
            navBarButtons.append(buildMoreNavBarAction())
        } else if moreInfoState.value == .shown {
            if productIsFavoriteable.value {
                navBarButtons.append(buildFavoriteNavBarAction())
            }
            navBarButtons.append(buildMoreNavBarAction())
        } else {
            navBarButtons.append(buildShareNavBarAction())
        }
        return navBarButtons
    }

    private func buildFavoriteNavBarAction() -> UIAction {
        let icon = UIImage(named: isFavorite.value ? "navbar_fav_on" : "navbar_fav_off")?
            .withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in
            self?.switchFavorite()
        }, accessibilityId: .productCarouselNavBarFavoriteButton)
    }

    private func buildEditNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_edit")?.withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in
            self?.editListing()
        }, accessibilityId: .productCarouselNavBarEditButton)
    }

    private func buildMoreNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_more")?.withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in self?.showOptionsMenu() },
                        accessibilityId: .productCarouselNavBarActionsButton)
    }

    private func buildShareNavBarAction() -> UIAction {
 		if DeviceFamily.current.isWiderOrEqualThan(.iPhone6) {
            return UIAction(interface: .textImage(LGLocalizedString.productShareNavbarButton, UIImage(named:"ic_share")), action: { [weak self] in
                self?.shareProduct()
            }, accessibilityId: .productCarouselNavBarShareButton)
        } else {
            return UIAction(interface: .text(LGLocalizedString.productShareNavbarButton), action: { [weak self] in
                self?.shareProduct()
            }, accessibilityId: .productCarouselNavBarShareButton)
        }
    }


    private func showOptionsMenu() {
        var actions = [UIAction]()

        if status.value.isEditable {
            actions.append(buildEditAction())
        }
        actions.append(buildShareAction())
        if productHasReadyCommercials.value {
            actions.append(buildCommercialAction())
        }
        if !isMine {
            actions.append(buildReportAction())
        }
        if isMine && status.value != .notAvailable {
            actions.append(buildDeleteAction())
        }

        delegate?.vmShowProductDetailOptions(LGLocalizedString.commonCancel, actions: actions)
    }

    private func buildEditAction() -> UIAction {
        return UIAction(interface: .text(LGLocalizedString.productOptionEdit), action: { [weak self] in
            self?.editListing()
        }, accessibilityId: .productCarouselNavBarEditButton)
    }

    private func buildShareAction() -> UIAction {
        return UIAction(interface: .text(LGLocalizedString.productOptionShare), action: { [weak self] in
            self?.shareProduct()
        }, accessibilityId: .productCarouselNavBarShareButton)
    }

    private func buildCommercialAction() -> UIAction {
        return UIAction(interface: .text(LGLocalizedString.productOptionShowCommercial), action: { [weak self] in
            self?.openVideo()
        })
    }

    private func buildReportAction() -> UIAction {
        let title = LGLocalizedString.productReportProductButton
        return UIAction(interface: .text(title), action: { [weak self] in self?.confirmToReportProduct() } )
    }
    
    fileprivate func confirmToReportProduct() {
        ifLoggedInRunActionElseOpenSignUp(from: .reportFraud, infoMessage: LGLocalizedString.productReportLoginPopupText) {
            [weak self] () -> () in
            guard let strongSelf = self, !strongSelf.isMine else { return }
            
            let alertOKAction = UIAction(interface: .text(LGLocalizedString.commonYes),
                action: { [weak self] in
                    self?.report()
                })
            strongSelf.delegate?.vmShowAlert(LGLocalizedString.productReportConfirmTitle,
                message: LGLocalizedString.productReportConfirmMessage,
                cancelLabel: LGLocalizedString.commonNo,
                actions: [alertOKAction])
        }
    }
    
    private func buildDeleteAction() -> UIAction {
        let title = LGLocalizedString.productDeleteConfirmTitle
        return UIAction(interface: .text(title), action: { [weak self] in
            guard let strongSelf = self else { return }

            let message: String
            var alertActions = [UIAction]()
            if strongSelf.suggestMarkSoldWhenDeleting {
                message = LGLocalizedString.productDeleteConfirmMessage

                let soldAction = UIAction(interface: .text(LGLocalizedString.productDeleteConfirmSoldButton),
                    action: { [weak self] in
                        self?.selectBuyerToMarkAsSold(showConfirmationFallback: false)
                    })
                alertActions.append(soldAction)

                let deleteAction = UIAction(interface: .text(LGLocalizedString.productDeleteConfirmOkButton),
                    action: { [weak self] in
                        self?.delete()
                    })
                alertActions.append(deleteAction)
            } else {
                message = LGLocalizedString.productDeleteSoldConfirmMessage

                let deleteAction = UIAction(interface: .text(LGLocalizedString.commonOk),
                    action: { [weak self] in
                        self?.delete()
                    })
                alertActions.append(deleteAction)
            }

            strongSelf.delegate?.vmShowAlert(LGLocalizedString.productDeleteConfirmTitle, message: message,
                cancelLabel: LGLocalizedString.productDeleteConfirmCancelButton,
                actions: alertActions)
            })
    }

    private var socialShareMessage: SocialMessage {
        return ProductSocialMessage(listing: listing.value, fallbackToStore: false)
    }

    private var suggestMarkSoldWhenDeleting: Bool {
        switch listing.value.status {
        case .pending, .discarded, .sold, .soldOld, .deleted:
            return false
        case .approved:
            return true
        }
    }
}


// MARK: - Helper Action buttons

extension ProductViewModel {

    fileprivate func refreshActionButtons(_ status: ProductViewModelStatus) {
        actionButtons.value = buildActionButtons(status)
    }

    private func buildActionButtons(_ status: ProductViewModelStatus) -> [UIAction] {
        var actionButtons = [UIAction]()
        switch status {
        case .pending, .notAvailable, .otherSold, .otherSoldFree:
            break
        case .available:
            actionButtons.append(UIAction(interface: .button(LGLocalizedString.productMarkAsSoldButton, .terciary),
                action: { [weak self] in self?.selectBuyerToMarkAsSold(showConfirmationFallback: true) }))
        case .sold:
            actionButtons.append(UIAction(interface: .button(LGLocalizedString.productSellAgainButton, .secondary(fontSize: .big, withBorder: false)),
                action: { [weak self] in self?.confirmToMarkAsUnSold(free: false) }))
        case .otherAvailable, .otherAvailableFree:
            break
        case .availableFree:
            actionButtons.append(UIAction(interface: .button(LGLocalizedString.productMarkAsSoldFreeButton, .terciary),
                action: { [weak self] in self?.selectBuyerToMarkAsSold(showConfirmationFallback: true) }))
        case .soldFree:
            actionButtons.append(UIAction(interface: .button(LGLocalizedString.productSellAgainFreeButton, .secondary(fontSize: .big, withBorder: false)),
                action: { [weak self] in self?.confirmToMarkAsUnSold(free: true) }))
        }
        return actionButtons
    }
}


// MARK: - Private actions

fileprivate extension ProductViewModel {

    func showItemHiddenIfNeededFor(url: URL) {
        guard let _ = TextHiddenTags(fromURL: url) else { return }

        let okAction = UIAction(interface: .button(LGLocalizedString.commonOk, .primary(fontSize: .big)), action: {})
        delegate?.vmShowAlertWithTitle(LGLocalizedString.hiddenTextAlertTitle,
                                       text: LGLocalizedString.hiddenTextAlertDescription,
                                       alertType: .iconAlert(icon: #imageLiteral(resourceName: "ic_safety_tips_big")),
                                       actions: [okAction])
    }

    func switchFavoriteAction() {
        guard favoriteButtonState.value != .disabled else { return }
        favoriteButtonState.value = .disabled
        let currentFavoriteValue = isFavorite.value
        isFavorite.value = !isFavorite.value
        if currentFavoriteValue {
            listingRepository.deleteFavorite(listing: listing.value) { [weak self] result in
                guard let strongSelf = self else { return }
                if let _ = result.error {
                    strongSelf.isFavorite.value = currentFavoriteValue
                }
                strongSelf.favoriteButtonState.value = .enabled
            }
        } else {
            listingRepository.saveFavorite(listing: listing.value) { [weak self] result in
                guard let strongSelf = self else { return }
                if let _ = result.value {
                    self?.trackHelper.trackSaveFavoriteCompleted(strongSelf.isShowingFeaturedStripe.value)

                    self?.navigator?.openAppRating(.favorite)
                } else {
                    strongSelf.isFavorite.value = currentFavoriteValue
                }
                strongSelf.favoriteButtonState.value = .enabled
            }

            if featureFlags.shouldContactSellerOnFavorite {
                navigator?.showProductFavoriteBubble(with: favoriteBubbleNotificationData())
            }
        }
    }
  
    func favoriteBubbleNotificationData() -> BubbleNotificationData {
        let action = UIAction(interface: .text(LGLocalizedString.productBubbleFavoriteButton), action: { [weak self] in
            self?.sendMessage(type: .favoritedProduct(LGLocalizedString.productFavoriteDirectMessage))
        }, accessibilityId: .bubbleButton)
        let data = BubbleNotificationData(tagGroup: ProductViewModel.bubbleTagGroup,
                                          text: LGLocalizedString.productBubbleFavoriteButton,
                                          infoText: LGLocalizedString.productBubbleFavoriteText,
                                          action: action,
                                          iconURL: nil,
                                          iconImage: UIImage(named: "user_placeholder"))
        return data
    }

    func selectBuyerToMarkAsSold(showConfirmationFallback: Bool) {
        guard featureFlags.userRatingMarkAsSold else {
            confirmToMarkAsSold()
            return
        }

        guard let productId = listing.value.objectId else { return }
        delegate?.vmShowLoading(nil)
        listingRepository.possibleBuyersOf(listingId: productId) { [weak self] result in
            if let buyers = result.value, !buyers.isEmpty {
                self?.delegate?.vmHideLoading(nil) {
                    self?.navigator?.selectBuyerToRate(source: .markAsSold, buyers: buyers) { [weak self] buyerId in
                        let userSoldTo: EventParameterUserSoldTo = buyerId != nil ? .letgoUser : .outsideLetgo
                        self?.markAsSold(buyerId: buyerId, userSoldTo: userSoldTo)
                    }
                }
            } else if showConfirmationFallback {
                self?.delegate?.vmHideLoading(nil) {
                    self?.confirmToMarkAsSold()
                }
            } else {
                self?.markAsSold(buyerId: nil, userSoldTo: .noConversations)
            }
        }
    }

    private func confirmToMarkAsSold() {
        guard isMine && status.value.isAvailable else { return }
        let free = status.value.isFree
        let okButton = free ? LGLocalizedString.productMarkAsSoldFreeConfirmOkButton : LGLocalizedString.productMarkAsSoldConfirmOkButton
        let title = free ? LGLocalizedString.productMarkAsSoldFreeConfirmTitle : LGLocalizedString.productMarkAsSoldConfirmTitle
        let message = free ? LGLocalizedString.productMarkAsSoldFreeConfirmMessage : LGLocalizedString.productMarkAsSoldConfirmMessage
        let cancel = free ? LGLocalizedString.productMarkAsSoldFreeConfirmCancelButton : LGLocalizedString.productMarkAsSoldConfirmCancelButton

        var alertActions: [UIAction] = []
        let markAsSoldAction = UIAction(interface: .text(okButton),
                                        action: { [weak self] in
                                            self?.markAsSold(buyerId: nil, userSoldTo: .noConversations)
        })
        alertActions.append(markAsSoldAction)
        delegate?.vmShowAlert(title, message: message, cancelLabel: cancel, actions: alertActions)
    }

    func confirmToMarkAsUnSold(free: Bool) {
        let okButton = free ? LGLocalizedString.productSellAgainFreeConfirmOkButton : LGLocalizedString.productSellAgainConfirmOkButton
        let title = free ? LGLocalizedString.productSellAgainFreeConfirmTitle : LGLocalizedString.productSellAgainConfirmTitle
        let message = free ? LGLocalizedString.productSellAgainFreeConfirmMessage : LGLocalizedString.productSellAgainConfirmMessage
        let cancel = free ? LGLocalizedString.productSellAgainFreeConfirmCancelButton : LGLocalizedString.productSellAgainConfirmCancelButton

        var alertActions: [UIAction] = []
        let sellAgainAction = UIAction(interface: .text(okButton),
                                       action: { [weak self] in
                                        self?.markUnsold()
        })
        alertActions.append(sellAgainAction)
        delegate?.vmShowAlert(title, message: message, cancelLabel: cancel, actions: alertActions)
    }

    func report() {
        guard let productId = listing.value.objectId else { return }
        if isReported.value {
            delegate?.vmHideLoading(LGLocalizedString.productReportedSuccessMessage, afterMessageCompletion: nil)
            return
        }
        delegate?.vmShowLoading(LGLocalizedString.productReportingLoadingMessage)

        listingRepository.saveReport(productId) { [weak self] result in
            guard let strongSelf = self else { return }

            var message: String? = nil
            if let _ = result.value {
                strongSelf.isReported.value = true
                message = LGLocalizedString.productReportedSuccessMessage
                self?.trackHelper.trackReportCompleted()
            } else if let _ = result.error {
                message = LGLocalizedString.productReportedErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    func delete() {
        guard let productId = listing.value.objectId else { return }
        delegate?.vmShowLoading(LGLocalizedString.commonLoading)
        trackHelper.trackDeleteStarted()

        listingRepository.delete(listingId: productId) { [weak self] result in
            var message: String? = nil
            var afterMessageAction: (() -> ())? = nil
            if let _ = result.value {
                afterMessageAction = { [weak self] in
                    self?.navigator?.closeAfterDelete()
                }
                self?.trackHelper.trackDeleteCompleted()
            } else if let _ = result.error {
                message = LGLocalizedString.productDeleteSendErrorGeneric
            }

            self?.delegate?.vmHideLoading(message, afterMessageCompletion: afterMessageAction)
        }
    }

    func markAsSold(buyerId: String?, userSoldTo: EventParameterUserSoldTo) {
        delegate?.vmShowLoading(nil)

        listingRepository.markAsSold(listing: listing.value, buyerId: buyerId) { [weak self] result in
            guard let strongSelf = self else { return }

            var markAsSoldCompletion: (()->())? = nil

            let message: String
            if let value = result.value {
                strongSelf.listing.value = value
                message = strongSelf.listing.value.price.free ? LGLocalizedString.productMarkAsSoldFreeSuccessMessage : LGLocalizedString.productMarkAsSoldSuccessMessage
                self?.trackHelper.trackMarkSoldCompleted(to: userSoldTo, isShowingFeaturedStripe: strongSelf.isShowingFeaturedStripe.value)
                markAsSoldCompletion = {
                    self?.navigator?.openAppRating(.markedSold)
                }
            } else {
                message = LGLocalizedString.productMarkAsSoldErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: markAsSoldCompletion)
        }
    }

    func markUnsold() {
        delegate?.vmShowLoading(nil)

        listingRepository.markAsUnsold(listing: listing.value) { [weak self] result in
            guard let strongSelf = self else { return }

            let message: String
            if let value = result.value {
                strongSelf.listing.value = value
                message = strongSelf.listing.value.price.free ? LGLocalizedString.productSellAgainFreeSuccessMessage : LGLocalizedString.productSellAgainSuccessMessage
                self?.trackHelper.trackMarkUnsoldCompleted()
            } else {
                message = LGLocalizedString.productSellAgainErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    func sendMessage(type: ChatWrapperMessageType) {
        // Optimistic behavior
        let message = LocalMessage(type: type, userId: myUserRepository.myUser?.objectId)
        let messageView = chatViewMessageAdapter.adapt(message)
        directChatMessages.insert(messageView, atIndex: 0)

        chatWrapper.sendMessageFor(listing: listing.value, type: type) { [weak self] result in
            guard let strongSelf = self else { return }
            if let firstMessage = result.value {
                strongSelf.trackHelper.trackMessageSent(firstMessage && !strongSelf.alreadyTrackedFirstMessageSent,
                                                   messageType: type, isShowingFeaturedStripe: strongSelf.isShowingFeaturedStripe.value)
                strongSelf.alreadyTrackedFirstMessageSent = true
            } else if let error = result.error {
                strongSelf.trackHelper.trackMessageSentError(messageType: type, isShowingFeaturedStripe: strongSelf.isShowingFeaturedStripe.value, error: error)
                switch error {
                case .forbidden:
                    strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.productChatDirectErrorBlockedUserMessage, completion: nil)
                case .network, .internalError, .notFound, .unauthorized, .tooManyRequests, .userNotVerified, .serverError:
                    strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.chatSendErrorGeneric, completion: nil)
                }

                //Removing in case of failure
                if let indexToRemove = strongSelf.directChatMessages.value.index(where: { $0.objectId == messageView.objectId }) {
                    strongSelf.directChatMessages.removeAtIndex(indexToRemove)
                }
            }
        }
    }
}


// MARK: - Logged in checks

extension ProductViewModel {
    fileprivate func ifLoggedInRunActionElseOpenSignUp(from: EventParameterLoginSourceValue,
                                                       infoMessage: String,
                                                       action: @escaping () -> ()) {
        navigator?.openLoginIfNeededFromProductDetail(from: from, infoMessage: infoMessage, loggedInAction: action)
    }
}


// MARK: - SocialSharerDelegate

extension ProductViewModel: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
        let buttonPosition: EventParameterButtonPosition

        switch moreInfoState.value {
        case .hidden:
            buttonPosition = .top
        case .shown, .moving:
            buttonPosition = .bottom
        }

        trackShareStarted(shareType, buttonPosition: buttonPosition)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        let buttonPosition: EventParameterButtonPosition

        switch moreInfoState.value {
        case .hidden:
            buttonPosition = .top
        case .shown, .moving:
            buttonPosition = .bottom
        }

        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShowAutoFadingMessage(message, completion: nil)
        }

        trackShareCompleted(shareType, buttonPosition: buttonPosition, state: state)
    }

    private func messageForShareIn(_ shareType: ShareType, finishedWithState state: SocialShareState) -> String? {
        switch (shareType, state) {
        case (.email, .failed):
            return LGLocalizedString.productShareEmailError
        case (.facebook, .failed):
            return LGLocalizedString.sellSendErrorSharingFacebook
        case (.fbMessenger, .failed):
            return LGLocalizedString.sellSendErrorSharingFacebook
        case (.copyLink, .completed):
            return LGLocalizedString.productShareCopylinkOk
        case (.sms, .completed):
            return LGLocalizedString.productShareSmsOk
        case (.sms, .failed):
            return LGLocalizedString.productShareSmsError
        case (_, .completed):
            return LGLocalizedString.productShareGenericOk
        default:
            break
        }
        return nil
    }
}


// MARK: PurchasesShopperDelegate

extension ProductViewModel: PurchasesShopperDelegate {
    func shopperFinishedProductsRequestForProductId(_ productId: String?, withProducts products: [PurchaseableProduct]) {
        guard let requestProdId = productId, let currentProdId = listing.value.objectId,
            requestProdId == currentProdId else { return }
        guard let purchase = products.first else { return }

        bumpUpPurchaseableProduct = purchase
        createBumpeableBanner(forListingId: requestProdId, withPrice: bumpUpPurchaseableProduct?.formattedCurrencyPrice,
                              paymentItemId: paymentItemId, bumpUpType: .priced)
    }


    // Free Bump Up
    func freeBumpDidStart() {
        delegate?.vmShowLoading(LGLocalizedString.bumpUpProcessingFreeText)
    }

    func freeBumpDidSucceed(withNetwork network: EventParameterShareNetwork) {
        trackHelper.trackBumpUpCompleted(.free, network: network)
        delegate?.vmHideLoading(LGLocalizedString.bumpUpFreeSuccess, afterMessageCompletion: { [weak self] in
            self?.delegate?.vmResetBumpUpBannerCountdown()
        })
    }

    func freeBumpDidFail(withNetwork network: EventParameterShareNetwork) {
        delegate?.vmHideLoading(LGLocalizedString.bumpUpErrorBumpGeneric, afterMessageCompletion: nil)
    }

    // Priced Bump Up
    func pricedBumpDidStart() {
        trackBumpUpStarted(.pay(price: bumpUpPurchaseableProduct?.formattedCurrencyPrice ?? ""))
        delegate?.vmShowLoading(LGLocalizedString.bumpUpProcessingPricedText)
    }

    func pricedBumpDidSucceed() {
        trackHelper.trackBumpUpCompleted(.pay(price: bumpUpPurchaseableProduct?.formattedCurrencyPrice ?? ""),
                                         network: .notAvailable)
        delegate?.vmHideLoading(LGLocalizedString.bumpUpPaySuccess, afterMessageCompletion: { [weak self] in
            self?.delegate?.vmResetBumpUpBannerCountdown()
        })
    }

    func pricedBumpDidFail() {
        delegate?.vmHideLoading(LGLocalizedString.bumpUpErrorBumpGeneric, afterMessageCompletion: { [weak self] in
            self?.refreshBumpeableBanner()
        })
    }

    func pricedBumpPaymentDidFail() {
        delegate?.vmHideLoading(LGLocalizedString.bumpUpErrorPaymentFailed, afterMessageCompletion: nil)
    }
}
