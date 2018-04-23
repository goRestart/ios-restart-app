//
//  ListingViewModel.swift
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


protocol ListingViewModelDelegate: BaseViewModelDelegate {

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?)

    var trackingFeedPosition: EventParameterFeedPosition { get }
    
    var listingOrigin: ListingOrigin { get }
    
    // Bump Up
    func vmResetBumpUpBannerCountdown()
}

protocol ListingViewModelMaker {
    func make(listing: Listing, visitSource: EventParameterListingVisitSource) -> ListingViewModel
    func make(listing: Listing, navigator: ListingDetailNavigator?, visitSource: EventParameterListingVisitSource) -> ListingViewModel

    func makeListingDeckSnapshot(listingViewModel: ListingViewModel) -> ListingDeckSnapshotType
    func makeListingDeckSnapshot(listing: Listing) -> ListingDeckSnapshotType
}

enum ListingOrigin {
    case initial, inResponseToNextRequest, inResponseToPreviousRequest
}

class ListingViewModel: BaseViewModel {
    class ConvenienceMaker: ListingViewModelMaker {

        func makeListingDeckSnapshot(listingViewModel: ListingViewModel) -> ListingDeckSnapshotType {
            return makeListingDeckSnapshot(listing: listingViewModel.listing.value,
                                           isFavorite: listingViewModel.isFavorite.value,
                                           isFeatured: listingViewModel.isShowingFeaturedStripe.value,
                                           socialMessage: listingViewModel.socialMessage.value)
        }

        func makeListingDeckSnapshot(listing: Listing) -> ListingDeckSnapshotType {
            return makeListingDeckSnapshot(listing: listing,
                                           isFavorite: false,
                                           isFeatured: false,
                                           socialMessage: nil,
                                           myUserRepository: Core.myUserRepository,
                                           featureFlags: FeatureFlags.sharedInstance,
                                           countryHelper: Core.countryHelper)
        }

        private func makeListingDeckSnapshot(listing: Listing,
                                             isFavorite: Bool,
                                             isFeatured: Bool,
                                             socialMessage: SocialMessage?) -> ListingDeckSnapshotType {
            return makeListingDeckSnapshot(listing: listing,
                                           isFavorite: isFavorite,
                                           isFeatured: isFeatured,
                                           socialMessage: socialMessage,
                                           myUserRepository: Core.myUserRepository,
                                           featureFlags: FeatureFlags.sharedInstance,
                                           countryHelper: Core.countryHelper)
        }

        private func makeListingDeckSnapshot(listing: Listing,
                                             isFavorite: Bool,
                                             isFeatured: Bool,
                                             socialMessage: SocialMessage?,
                                 myUserRepository: MyUserRepository,
                                 featureFlags: FeatureFlags,
                                 countryHelper: CountryHelper) -> ListingDeckSnapshotType {
            let isMine = listing.isMine(myUserRepository: myUserRepository)
            let status = ListingViewModelStatus(listing: listing,
                                                isMine: listing.isMine(myUserRepository: myUserRepository),
                                                featureFlags: featureFlags)
            let info = ListingVMProductInfo(listing: listing,
                                            isAutoTranslated: listing.isTitleAutoTranslated(countryHelper),
                                            distance: nil,
                                            freeModeAllowed: featureFlags.freePostingModeAllowed,
                                            postingFlowType: featureFlags.postingFlowType)
            let userInfo = ListingVMUserInfo(userListing: listing.user, myUser: myUserRepository.myUser)
            return ListingDeckSnapshot(preview: listing.images.first?.fileURL,
                                       imageCount: listing.images.count,
                                       isFavoritable: isMine,
                                       isFavorite: isFavorite,
                                       userInfo: userInfo,
                                       status: status,
                                       isFeatured: isFeatured,
                                       productInfo: info,
                                       stats: nil,
                                       postedDate: nil,
                                       socialSharer: SocialSharer(),
                                       socialMessage: socialMessage,
                                       isMine: isMine)
        }

        func make(listing: Listing, visitSource source: EventParameterListingVisitSource) -> ListingViewModel {
            return ListingViewModel(listing: listing,
                                    visitSource: source,
                                    myUserRepository: Core.myUserRepository,
                                    userRepository: Core.userRepository,
                                    listingRepository: Core.listingRepository,
                                    chatWrapper: LGChatWrapper(),
                                    chatViewMessageAdapter: ChatViewMessageAdapter(),
                                    locationManager: Core.locationManager,
                                    countryHelper: Core.countryHelper,
                                    socialSharer: SocialSharer(),
                                    featureFlags: FeatureFlags.sharedInstance,
                                    purchasesShopper: LGPurchasesShopper.sharedInstance,
                                    monetizationRepository: Core.monetizationRepository,
                                    tracker: TrackerProxy.sharedInstance,
                                    keyValueStorage: KeyValueStorage.sharedInstance)
        }

        func make(listing: Listing, navigator: ListingDetailNavigator?,
                  visitSource: EventParameterListingVisitSource) -> ListingViewModel {
            let viewModel = make(listing: listing, visitSource: visitSource)
            viewModel.navigator = navigator
            return viewModel
        }

    }

    // Delegate
    weak var delegate: ListingViewModelDelegate?
    weak var navigator: ListingDetailNavigator?

    // Data
    let listing: Variable<Listing>
    var isMine: Bool {
        return listing.value.isMine(myUserRepository: myUserRepository)
    }
    
    let seller = Variable<User?>(nil)
    let isFavorite = Variable<Bool>(false)
    let listingStats = Variable<ListingStats?>(nil)
    let showExactLocationOnMap = Variable<Bool>(false)
    private var myUserId: String? {
        return myUserRepository.myUser?.objectId
    }
    private var myUserName: String? {
        return myUserRepository.myUser?.name
    }

    lazy var socialMessage = Variable<SocialMessage?>(nil)
    let socialSharer: SocialSharer
    fileprivate var freeBumpUpShareMessage: SocialMessage?

    let directChatMessages = CollectionVariable<ChatViewMessage>([])
    var quickAnswers: [QuickAnswer] {
        guard !isMine else { return [] }
        let isFree = listing.value.price.isFree && featureFlags.freePostingModeAllowed
        return QuickAnswer.quickAnswersForPeriscope(isFree: isFree)
    }

    lazy var navBarButtons = Variable<[UIAction]>([])
    lazy var actionButtons = Variable<[UIAction]>([])
    lazy var altActions = Variable<[UIAction]>([])

    var navBarActionsNewItemPage: [UIAction] {
        var navBarButtons = [UIAction]()
        if isMine {
            if status.value.isEditable && isListingDetailsCompleted.value {
                navBarButtons.append(buildEditAction())
            }
            navBarButtons.append(buildDeleteAction())
        } else {
            navBarButtons.append(buildReportAction())
        }
        navBarButtons.insert(buildShareAction(), at: navBarButtons.count - 1)
        return navBarButtons
    }

    lazy var directChatEnabled = Variable<Bool>(false)
    var directChatPlaceholder: String {
        let userName = listing.value.user.name?.toNameReduced(maxChars: Constants.maxCharactersOnUserNameChatButton) ?? ""
        return LGLocalizedString.productChatWithSellerNameButton(userName)
    }
    fileprivate lazy var productIsFavoriteable = Variable<Bool>(false)
    lazy var favoriteButtonState = Variable<ButtonState>(.enabled)
    lazy var shareButtonState = Variable<ButtonState>(.hidden)

    lazy var productInfo = Variable<ListingVMProductInfo?>(nil)
//    lazy var productImageURLs = Variable<[URL]>([])
    lazy var productMedia = Variable<[Media]>([])
    lazy var previewURL = Variable<(URL?, Int)>((nil, 0))
    lazy var videoProgress = Variable<(CGFloat)>(0.0)

    let userInfo: Variable<ListingVMUserInfo>

    let status = Variable<ListingViewModelStatus>(.pending)
    
    fileprivate var isTransactionOpen: Bool = false

    fileprivate let isReported = Variable<Bool>(false)

    lazy var bumpUpBannerInfo = Variable<BumpUpInfo?>(nil)
    fileprivate var timeSinceLastBump: TimeInterval = 0
    fileprivate var bumpMaxCountdown: TimeInterval = 0
    var bumpUpPurchaseableProduct: PurchaseableProduct?
    private var isUpdatingBumpUpBanner: Bool = false
    private var letgoItemId: String?
    var storeProductId: String?
    private var userIsSoftBlocked: Bool = false
    private var bumpUpSource: BumpUpSource?
    private var isPromotedBump: Bool {
        guard let bumpSource = bumpUpSource else { return false }
        switch bumpSource {
        case .promoted:
            return true
        case .deepLink, .edit:
            return false
        }
    }

    fileprivate var alreadyTrackedFirstMessageSent: Bool = false
    fileprivate static let bubbleTagGroup = "favorite.bubble.group"

    // UI - Input
    let moreInfoState = Variable<MoreInfoState>(.hidden)

    // Repository, helpers & tracker
    let trackHelper: ProductVMTrackHelper
    var sellerAverageUserRating: Float?

    fileprivate let myUserRepository: MyUserRepository
    fileprivate let userRepository: UserRepository
    fileprivate let listingRepository: ListingRepository
    fileprivate let chatWrapper: ChatWrapper
    fileprivate let countryHelper: CountryHelper
    fileprivate let locationManager: LocationManager
    fileprivate let chatViewMessageAdapter: ChatViewMessageAdapter
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let purchasesShopper: PurchasesShopper
    fileprivate let monetizationRepository: MonetizationRepository
    fileprivate let showFeaturedStripeHelper: ShowFeaturedStripeHelper
    fileprivate let visitSource: EventParameterListingVisitSource
    fileprivate let keyValueStorage: KeyValueStorageable

    lazy var isShowingFeaturedStripe = Variable<Bool>(false)
    fileprivate lazy var isListingDetailsCompleted = Variable<Bool>(false)

    // Retrieval status
    private var relationRetrieved = false

    // Rx
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    init(listing: Listing,
         visitSource: EventParameterListingVisitSource,
         myUserRepository: MyUserRepository,
         userRepository: UserRepository,
         listingRepository: ListingRepository,
         chatWrapper: ChatWrapper,
         chatViewMessageAdapter: ChatViewMessageAdapter,
         locationManager: LocationManager,
         countryHelper: CountryHelper,
         socialSharer: SocialSharer,
         featureFlags: FeatureFlaggeable,
         purchasesShopper: PurchasesShopper,
         monetizationRepository: MonetizationRepository,
         tracker: Tracker,
         keyValueStorage: KeyValueStorageable) {
        self.listing = Variable<Listing>(listing)
        self.visitSource = visitSource
        self.socialSharer = socialSharer
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.listingRepository = listingRepository
        self.countryHelper = countryHelper
        self.trackHelper = ProductVMTrackHelper(tracker: tracker, listing: listing, featureFlags: featureFlags)
        self.keyValueStorage = keyValueStorage
        self.chatWrapper = chatWrapper
        self.locationManager = locationManager
        self.chatViewMessageAdapter = chatViewMessageAdapter
        self.featureFlags = featureFlags
        self.purchasesShopper = purchasesShopper
        self.monetizationRepository = monetizationRepository
        self.showFeaturedStripeHelper = ShowFeaturedStripeHelper(featureFlags: featureFlags, myUserRepository: myUserRepository)
        self.userInfo = Variable<ListingVMUserInfo>(ListingVMUserInfo(userListing: listing.user, myUser: myUserRepository.myUser))
        self.disposeBag = DisposeBag()


        super.init()

        socialSharer.delegate = self
        setupRxBindings()
    }
    
    internal override func didBecomeActive(_ firstTime: Bool) {
        guard let listingId = listing.value.objectId else { return }

        if  listing.value.isRealEstate
            && listing.value.realEstate?.realEstateAttributes == RealEstateAttributes.emptyRealEstateAttributes() {
            retrieveRealEstateDetails(listingId: listingId)
        } else {
            isListingDetailsCompleted.value = true
        }

        if featureFlags.allowCallsForProfessionals.isActive {
            if isMine {
                seller.value = myUserRepository.myUser
            } else if let userId = userInfo.value.userId {
                userRepository.show(userId) { [weak self] result in
                    guard let strongSelf = self else { return }
                    if let value = result.value {
                        strongSelf.seller.value = value
                        strongSelf.sellerAverageUserRating = value.ratingAverage
                    }
                }
            }
        }

        listingRepository.incrementViews(listingId: listingId,
                                         visitSource: visitSource.rawValue,
                                         visitTimestamp: Date().millisecondsSince1970,
                                         completion: nil)

        if !relationRetrieved && myUserRepository.myUser != nil {
            listingRepository.retrieveUserListingRelation(listingId) { [weak self] result in
                guard let value = result.value  else { return }
                self?.relationRetrieved = true
                self?.isFavorite.value = value.isFavorited
                self?.isReported.value = value.isReported
            }
        }
        
        if isMine && status.value.isSold {
            syncTransactions()
        }

        if listingStats.value == nil {
            listingRepository.retrieveStats(listingId: listingId) { [weak self] result in
                guard let stats = result.value else { return }
                self?.listingStats.value = stats
            }
        }

        purchasesShopper.delegate = self
        purchasesShopper.bumpInfoRequesterDelegate = self

        if bumpUpBannerInfo.value == nil {
            refreshBumpeableBanner()
        }
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        bumpUpBannerInfo.value = nil
        altActions.value = []
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
    
    func syncTransactions() {
        guard let listingId = listing.value.objectId else { return }
        listingRepository.retrieveTransactionsOf(listingId: listingId) { [weak self] (result) in
            guard let transaction = result.value?.first else { return }
            self?.isTransactionOpen = !transaction.closed
        }
    }

    private func setupRxBindings() {
//        productImageURLs.asObservable().bind { [weak self] urls in
//            self?.previewURL.value = (urls.first, urls.count)
//        }.disposed(by: disposeBag)

        productMedia.asObservable().bind { [weak self] media in
            self?.previewURL.value = (media.first?.outputs.image, media.count)
            }.disposed(by: disposeBag)

        if let productId = listing.value.objectId {
            listingRepository.updateEvents(for: productId).bind { [weak self] listing in
                self?.listing.value = listing
            }.disposed(by: disposeBag)
        }

        let listingActions = Observable.combineLatest(status.asObservable(), seller.asObservable()) { ($0, $1) }

        listingActions.asObservable().bind { [weak self] (status, seller) in
            guard let strongSelf = self else { return }
            let sellerIsProfessional = seller?.isProfessional ?? false
            strongSelf.refreshActionButtons(status, isProfessional: sellerIsProfessional)
            strongSelf.refreshNavBarButtons()
            strongSelf.directChatEnabled.value = status.directChatsAvailable && !sellerIsProfessional
        }.disposed(by: disposeBag)
        
        isListingDetailsCompleted.asObservable().filter {$0}.bind { [weak self] _ in
            self?.refreshNavBarButtons()
        }.disposed(by: disposeBag)

        // bumpeable listing check
        status.asObservable().skip(1).bind { [weak self] status in
            guard let strongSelf = self else  { return }
            guard strongSelf.active else { return }
            let pendingAreBumpeable = strongSelf.featureFlags.showBumpUpBannerOnNotValidatedListings.isActive
            if status.shouldRefreshBumpBanner(pendingAreBumpeable: pendingAreBumpeable) {
                self?.refreshBumpeableBanner()
            } else {
                self?.bumpUpBannerInfo.value = nil
            }
        }.disposed(by: disposeBag)

        isFavorite.asObservable().subscribeNext { [weak self] _ in
            self?.refreshNavBarButtons()
        }.disposed(by: disposeBag)

        listing.asObservable().subscribeNext { [weak self] listing in
            guard let strongSelf = self else { return }
            strongSelf.trackHelper.listing = listing
            let isMine = listing.isMine(myUserRepository: strongSelf.myUserRepository)
            strongSelf.status.value = ListingViewModelStatus(listing: listing, isMine: isMine, featureFlags: strongSelf.featureFlags)

            strongSelf.isShowingFeaturedStripe.value = strongSelf.showFeaturedStripeHelper.shouldShowFeaturedStripeFor(listing: listing) && !strongSelf.status.value.shouldShowStatus

            strongSelf.productIsFavoriteable.value = !isMine
            strongSelf.socialMessage.value = ListingSocialMessage(listing: listing,
                                                                  fallbackToStore: false,
                                                                  myUserId: strongSelf.myUserId,
                                                                  myUserName: strongSelf.myUserName)
            strongSelf.freeBumpUpShareMessage = ListingSocialMessage(listing: listing,
                                                                     fallbackToStore: true,
                                                                     myUserId: strongSelf.myUserId,
                                                                     myUserName: strongSelf.myUserName)
//            strongSelf.productImageURLs.value = listing.images.flatMap { return $0.fileURL }
            strongSelf.productMedia.value = listing.media

            let productInfo = ListingVMProductInfo(listing: listing,
                                                   isAutoTranslated: listing.isTitleAutoTranslated(strongSelf.countryHelper),
                                                   distance: strongSelf.distanceString(listing),
                                                   freeModeAllowed: strongSelf.featureFlags.freePostingModeAllowed,
                                                   postingFlowType: strongSelf.featureFlags.postingFlowType)
            strongSelf.productInfo.value = productInfo

        }.disposed(by: disposeBag)

        status.asObservable().bind { [weak self] status in
            guard let isMine = self?.isMine else { return }
            self?.shareButtonState.value = isMine ? .enabled : .hidden
        }.disposed(by: disposeBag)

        myUserRepository.rx_myUser.bind { [weak self] _ in
            self?.refreshStatus()
        }.disposed(by: disposeBag)

        productIsFavoriteable.asObservable().bind { [weak self] favoriteable in
            self?.favoriteButtonState.value = favoriteable ? .enabled : .hidden
        }.disposed(by: disposeBag)

        moreInfoState.asObservable().map { (state: MoreInfoState) in
            return state == .shown
        }.distinctUntilChanged().bind { [weak self] shown in
            self?.refreshNavBarButtons()
        }.disposed(by: disposeBag)

        seller.asObservable().map { [weak self] in ($0?.isProfessional ?? false) &&
            (self?.featureFlags.showExactLocationForPros ?? false) }
            .bind(to: showExactLocationOnMap)
            .disposed(by: disposeBag)

    }
    
    private func distanceString(_ listing: Listing) -> String? {
        guard let userLocation = locationManager.currentLocation?.location else { return nil }
        let distance = listing.location.distanceTo(userLocation)
        let distanceString = String(format: "%0.1f %@", arguments: [distance, DistanceType.systemDistanceType().string])
        return LGLocalizedString.productDistanceXFromYou(distanceString)
    }

    private func refreshStatus() {
        status.value = ListingViewModelStatus(listing: listing.value, isMine: isMine, featureFlags: featureFlags)
    }
    
    private func retrieveRealEstateDetails(listingId: String) {
        listingRepository.retrieveRealEstate(listingId) { [weak self] (result) in
            guard let realEstateListing = result.value else { return }
            self?.listing.value = realEstateListing
            self?.isListingDetailsCompleted.value = true
        }
    }

    func refreshBumpeableBanner() {
        guard isMine else { return }
        let pendingAreBumpeable = featureFlags.showBumpUpBannerOnNotValidatedListings.isActive
        guard let listingId = listing.value.objectId,
            status.value.shouldRefreshBumpBanner(pendingAreBumpeable: pendingAreBumpeable),
            !isUpdatingBumpUpBanner,
            (featureFlags.freeBumpUpEnabled || featureFlags.pricedBumpUpEnabled) else { return }

        let isBumpUpPending = purchasesShopper.isBumpUpPending(forListingId: listingId)

        if isBumpUpPending {
            createBumpeableBanner(forListingId: listingId, withPrice: nil, letgoItemId: nil, storeProductId: nil,
                                  bumpUpType: .restore)
        } else if let timeOfRecentBump = purchasesShopper.timeSinceRecentBumpFor(listingId: listingId) {
            createBumpeableBannerForRecent(listingId: listingId, bumpUpType: bumpUpType, withTime: timeOfRecentBump)
        } else {
            isUpdatingBumpUpBanner = true
            monetizationRepository.retrieveBumpeableListingInfo(
                listingId: listingId,
                withHigherMinimumPrice: featureFlags.bumpPriceVariationBucket.rawValue,
                completion: { [weak self] result in
                    guard let strongSelf = self else { return }
                    strongSelf.isUpdatingBumpUpBanner = false
                    guard let bumpeableProduct = result.value else { return }

                    strongSelf.timeSinceLastBump = bumpeableProduct.timeSinceLastBump
                    strongSelf.bumpMaxCountdown = bumpeableProduct.maxCountdown
                    let freeItems = bumpeableProduct.paymentItems.filter { $0.provider == .letgo }
                    let paymentItems = bumpeableProduct.paymentItems.filter { $0.provider == .apple }
                    let hiddenItems = bumpeableProduct.paymentItems.filter { $0.provider == .hidden }
                    if !paymentItems.isEmpty, strongSelf.featureFlags.pricedBumpUpEnabled {
                        strongSelf.userIsSoftBlocked = false
                        // will be considered bumpeable ONCE WE GOT THE PRICES of the products, not before.
                        strongSelf.letgoItemId = paymentItems.first?.itemId
                        strongSelf.storeProductId = paymentItems.first?.providerItemId
                        // if "letgoItemId" is nil, the banner creation will fail, so we check this here to avoid
                        // a useless request to apple
                        if let letgoItemId = strongSelf.letgoItemId {
                            strongSelf.purchasesShopper.productsRequestStartForListingId(listingId,
                                                                                         letgoItemId: letgoItemId,
                                                                                         withIds: paymentItems.map { $0.providerItemId },
                                                                                         typePage: .listingDetail)
                        }
                    } else if !freeItems.isEmpty, strongSelf.featureFlags.freeBumpUpEnabled {
                        strongSelf.letgoItemId = freeItems.first?.itemId
                        strongSelf.storeProductId = freeItems.first?.providerItemId
                        strongSelf.createBumpeableBanner(forListingId: listingId,
                                                         withPrice: nil,
                                                         letgoItemId: strongSelf.letgoItemId,
                                                         storeProductId: strongSelf.storeProductId,
                                                         bumpUpType: .free)
                    } else if !hiddenItems.isEmpty, strongSelf.featureFlags.pricedBumpUpEnabled {
                        strongSelf.userIsSoftBlocked = true
                        // for hidden items we follow THE SAME FLOW we do for PAID items
                        strongSelf.letgoItemId = hiddenItems.first?.itemId
                        strongSelf.storeProductId = hiddenItems.first?.providerItemId
                        // if "letgoItemId" is nil, the banner creation will fail, so we check this here to avoid
                        // a useless request to apple
                        if let letgoItemId = strongSelf.letgoItemId {
                            strongSelf.purchasesShopper.productsRequestStartForListingId(listingId,
                                                                                         letgoItemId: letgoItemId,
                                                                                         withIds: hiddenItems.map { $0.providerItemId },
                                                                                         typePage: .listingDetail)
                        }
                    }
            })
        }
    }

    fileprivate func createBumpeableBanner(forListingId listingId: String,
                                           withPrice: String?,
                                           letgoItemId: String?,
                                           storeProductId: String?,
                                           bumpUpType: BumpUpType) {
        var bannerInteractionBlock: (TimeInterval?) -> Void
        var buttonBlock: (TimeInterval?) -> Void
        switch bumpUpType {
        case .free:
            guard let letgoItemId = letgoItemId else { return }
            let freeBlock: (TimeInterval?) -> Void = { [weak self] _ in
                guard let listing = self?.listing.value, let socialMessage = self?.freeBumpUpShareMessage else { return }

                let bumpUpProductData = BumpUpProductData(bumpUpPurchaseableData: .socialMessage(message: socialMessage),
                                                          letgoItemId: letgoItemId,
                                                          storeProductId: storeProductId)
                self?.navigator?.openFreeBumpUp(forListing: listing,
                                                bumpUpProductData: bumpUpProductData,
                                                typePage: .listingDetail)
            }
            bannerInteractionBlock = freeBlock
            buttonBlock = freeBlock
        case .priced:
            guard let letgoItemId = letgoItemId else { return }
            bannerInteractionBlock = { [weak self] _ in
                guard let _ = self?.listing.value else { return }
                guard let purchaseableProduct = self?.bumpUpPurchaseableProduct else { return }

                let bumpUpProductData = BumpUpProductData(bumpUpPurchaseableData: .purchaseableProduct(product: purchaseableProduct),
                                                          letgoItemId: letgoItemId,
                                                          storeProductId: storeProductId)

                self?.openPricedBumpUpView(bumpUpProductData: bumpUpProductData,
                                           typePage: .listingDetail)
            }
            buttonBlock = { [weak self] _ in
                self?.bumpUpProduct(productId: listingId, isBoost: false)
            }
        case .boost:
            guard let letgoItemId = letgoItemId else { return }
            bannerInteractionBlock = { [weak self] timeSinceLastBump in
                guard let _ = self?.listing.value else { return }
                guard let purchaseableProduct = self?.bumpUpPurchaseableProduct else { return }

                let bumpUpProductData = BumpUpProductData(bumpUpPurchaseableData: .purchaseableProduct(product: purchaseableProduct),
                                                          letgoItemId: letgoItemId,
                                                          storeProductId: storeProductId)

                self?.openBoostBumpUpView(bumpUpProductData: bumpUpProductData,
                                          typePage: .listingDetail,
                                          timeSinceLastBump: timeSinceLastBump)
            }
            buttonBlock = { [weak self] _ in
                self?.bumpUpProduct(productId: listingId, isBoost: true)
            }
        case .restore:
            let restoreBlock: (TimeInterval?) -> Void = { [weak self] _ in
                logMessage(.info, type: [.monetization], message: "TRY TO Restore Bump for listing: \(listingId)")
                self?.purchasesShopper.restorePaidBumpUp(forListingId: listingId)
            }
            bannerInteractionBlock = restoreBlock
            buttonBlock = restoreBlock
        case .hidden:
            let hiddenBlock: (TimeInterval?) -> Void = { [weak self] _ in
                self?.trackBumpUpNotAllowed(reason: .notAllowedInternal)
                let contactUsInterface = UIActionInterface.button(LGLocalizedString.bumpUpNotAllowedAlertContactButton,
                                                                  .primary(fontSize: .medium))
                let contactUsAction: UIAction = UIAction(interface: contactUsInterface,
                                                         action: { [weak self] in
                                                            self?.bumpUpHiddenProductContactUs()
                    },
                                                         accessibilityId: .bumpUpHiddenListingAlertContactButton)

                let cancelInterface = UIActionInterface.button(LGLocalizedString.commonCancel,
                                                               .secondary(fontSize: .medium, withBorder: true))
                let cancelAction: UIAction = UIAction(interface: cancelInterface,
                                                      action: {},
                                                      accessibilityId: .bumpUpHiddenListingAlertCancelButton)


                self?.navigator?.showBumpUpNotAvailableAlertWithTitle(title: LGLocalizedString.commonErrorTitle,
                                                                      text: LGLocalizedString.bumpUpNotAllowedAlertText,
                                                                      alertType: .plainAlert,
                                                                      buttonsLayout: .vertical,
                                                                      actions: [contactUsAction, cancelAction])
            }
            bannerInteractionBlock = hiddenBlock
            buttonBlock = hiddenBlock
        }

        bumpUpBannerInfo.value = BumpUpInfo(type: bumpUpType,
                                            timeSinceLastBump: timeSinceLastBump,
                                            maxCountdown: bumpMaxCountdown,
                                            price: withPrice,
                                            bannerInteractionBlock: bannerInteractionBlock,
                                            buttonBlock: buttonBlock)
    }
    fileprivate func createBumpeableBannerForRecent(listingId: String,
                                                    bumpUpType: BumpUpType,
                                                    withTime: TimeInterval) {
        var updatedBumpUpType = bumpUpType
        if (bumpUpType == .priced || bumpUpType.isBoost) && featureFlags.bumpUpBoost.isActive {
            updatedBumpUpType = .boost(boostBannerVisible: false)
        }
        bumpUpBannerInfo.value = BumpUpInfo(type: updatedBumpUpType,
                                            timeSinceLastBump: withTime,
                                            maxCountdown: bumpMaxCountdown,
                                            price: nil,
                                            bannerInteractionBlock: { _ in },
                                            buttonBlock: { _ in })
    }

    func bumpUpHiddenProductContactUs() {
        trackBumpUpNotAllowedContactUs(reason: .notAllowedInternal)
        navigator?.openContactUs(forListing: listing.value, contactUstype: .bumpUpNotAllowed)
    }


    func showBumpUpView(bumpUpProductData: BumpUpProductData,
                        bumpUpType: BumpUpType,
                        bumpUpSource: BumpUpSource?,
                        typePage: EventParameterTypePage?) {
        self.bumpUpSource = bumpUpSource
        switch bumpUpType {
        case .priced, .boost:
            guard bumpUpProductData.hasPaymentId else { return }
            openPricedBumpUpView(bumpUpProductData: bumpUpProductData,
                                 typePage: typePage)
        case .free, .hidden, .restore:
            break
        }
    }

    func openPricedBumpUpView(bumpUpProductData: BumpUpProductData,
                              typePage: EventParameterTypePage?) {
        navigator?.openPayBumpUp(forListing: listing.value,
                                 bumpUpProductData: bumpUpProductData,
                                 typePage: typePage)
    }

    func openBoostBumpUpView(bumpUpProductData: BumpUpProductData,
                             typePage: EventParameterTypePage?,
                             timeSinceLastBump: TimeInterval?) {
        navigator?.openBumpUpBoost(forListing: listing.value,
                                   bumpUpProductData: bumpUpProductData,
                                   typePage: typePage,
                                   timeSinceLastBump: timeSinceLastBump ?? self.timeSinceLastBump,
                                   maxCountdown: bumpMaxCountdown)
    }

    func bumpUpBoostSucceeded() {
        navigator?.showBumpUpBoostSucceededAlert()
    }

    private var listingCanBeBoosted: Bool {
        guard let threshold = featureFlags.bumpUpBoost.boostBannerUIUpdateThreshold else { return false }
        return timeSinceLastBump > threshold
    }

    private var hasBumpInProgress: Bool {
        return timeSinceLastBump > 0
    }
}


// MARK: - Public actions

extension ListingViewModel {

    func openProductOwnerProfile() {
        let data = UserDetailData.userAPI(user: LocalUser(userListing: listing.value.user), source: .listingDetail)
        navigator?.openUser(data)
    }

    func editListing() {
        guard myUserId == listing.value.user.objectId else { return }
        var bumpUpProductData: BumpUpProductData? = nil
        if let purchaseableProduct = bumpUpPurchaseableProduct, featureFlags.promoteBumpInEdit.isActive {
            bumpUpProductData = BumpUpProductData(bumpUpPurchaseableData: .purchaseableProduct(product: purchaseableProduct),
                                                  letgoItemId: letgoItemId,
                                                  storeProductId: storeProductId)
        }
        navigator?.editListing(listing.value,
                               bumpUpProductData: bumpUpProductData,
                               listingCanBeBoosted: listingCanBeBoosted,
                               timeSinceLastBump: timeSinceLastBump,
                               maxCountdown: bumpMaxCountdown)
    }

    func shareProduct() {
        guard let socialMessage = socialMessage.value else { return }
        guard let delegate = delegate else { return }
        let (vc, item) = delegate.vmShareViewControllerAndItem()
        socialSharer.share(socialMessage, shareType: .native(restricted: false),
                           viewController: vc,
                           barButtonItem: item)
    }

    func chatWithSeller() {
        guard let seller = seller.value else { return }
        let source: EventParameterTypePage = (moreInfoState.value == .shown) ? .listingDetailMoreInfo : .listingDetail
        trackHelper.trackChatWithSeller(source)
        navigator?.openListingChat(listing.value, source: .listingDetail, interlocutor: seller)
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

    func switchFavorite() {
        ifLoggedInRunActionElseOpenSignUp(from: .favourite, infoMessage: LGLocalizedString.productFavoriteLoginPopupText) {
            [weak self] in self?.switchFavoriteAction()
        }
    }

    func bumpUpProduct(productId: String, isBoost: Bool) {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump with purchase: \(String(describing: bumpUpPurchaseableProduct))")
        guard let purchaseableProduct = bumpUpPurchaseableProduct,
            let letgoItemId = letgoItemId else { return }
        purchasesShopper.requestPayment(forListingId: productId,
                                        appstoreProduct: purchaseableProduct,
                                        letgoItemId: letgoItemId,
                                        isBoost: isBoost)
    }

    func titleURLPressed(_ url: URL) {
        showItemHiddenIfNeededFor(url: url)
    }

    func descriptionURLPressed(_ url: URL) {
        showItemHiddenIfNeededFor(url: url)
    }

    func markAsSold() {
        guard myUserId == listing.value.user.objectId else { return }
        delegate?.vmShowLoading(nil)
        listingRepository.markAsSold(listing: listing.value) { [weak self] result in
            guard let strongSelf = self else { return }
            
            if let value = result.value {
                strongSelf.listing.value = value
                strongSelf.trackHelper.trackMarkSoldCompleted(isShowingFeaturedStripe: strongSelf.isShowingFeaturedStripe.value)
                strongSelf.selectBuyerToMarkAsSold(sourceRateBuyers: .markAsSold)
            } else {
                let message = LGLocalizedString.productMarkAsSoldErrorGeneric
                strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
            }
        }
    }

    func openAskPhone() {
        ifLoggedInRunActionElseOpenSignUp(from: .chatProUser, infoMessage: LGLocalizedString.chatLoginPopupText) { [weak self] in
            guard let strongSelf = self else  { return }
            if let listingId = strongSelf.listing.value.objectId,
                strongSelf.keyValueStorage.proSellerAlreadySentPhoneInChat.contains(listingId) {
                strongSelf.chatWithSeller()
            } else {
                strongSelf.navigator?.openAskPhoneFor(listing: strongSelf.listing.value,
                                                      interlocutor: strongSelf.seller.value)
            }
        }
    }
}


// MARK: - Helper Navbar

extension ListingViewModel {

    fileprivate func refreshNavBarButtons() {
        navBarButtons.value = buildNavBarButtons()
    }

    private func buildNavBarButtons() -> [UIAction] {
        var navBarButtons = [UIAction]()

        if isMine {
            if status.value.isEditable && isListingDetailsCompleted.value {
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
        }, accessibilityId: .listingCarouselNavBarFavoriteButton)
    }

    private func buildEditNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_edit")?.withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in
            self?.editListing()
        }, accessibilityId: .listingCarouselNavBarEditButton)
    }

    private func buildMoreNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_more")?.withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in self?.updateAltActions() },
                        accessibilityId: .listingCarouselNavBarActionsButton)
    }

    private func buildShareNavBarAction() -> UIAction {
 		if DeviceFamily.current.isWiderOrEqualThan(.iPhone6) {
            return UIAction(interface: .textImage(LGLocalizedString.productShareNavbarButton, UIImage(named:"ic_share")), action: { [weak self] in
                self?.shareProduct()
            }, accessibilityId: .listingCarouselNavBarShareButton)
        } else {
            return UIAction(interface: .text(LGLocalizedString.productShareNavbarButton), action: { [weak self] in
                self?.shareProduct()
            }, accessibilityId: .listingCarouselNavBarShareButton)
        }
    }


    private func updateAltActions() {
        var actions = [UIAction]()

        if status.value.isEditable {
            actions.append(buildEditAction())
        }
        actions.append(buildShareAction())
        if !isMine {
            actions.append(buildReportAction())
        }
        if isMine && status.value != .notAvailable {
            actions.append(buildDeleteAction())
        }

        altActions.value = actions
    }

    private func buildEditAction() -> UIAction {
        return UIAction(interface: .text(LGLocalizedString.productOptionEdit), action: { [weak self] in
            self?.editListing()
        }, accessibilityId: .listingCarouselNavBarEditButton)
    }

    private func buildShareAction() -> UIAction {
        return UIAction(interface: .text(LGLocalizedString.productOptionShare), action: { [weak self] in
            self?.shareProduct()
        }, accessibilityId: .listingCarouselNavBarShareButton)
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
                        self?.confirmToMarkAsSold()
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
        return ListingSocialMessage(listing: listing.value,
                                    fallbackToStore: false,
                                    myUserId: myUserId,
                                    myUserName: myUserName)
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

extension ListingViewModel {

    fileprivate func refreshActionButtons(_ status: ListingViewModelStatus, isProfessional: Bool) {
        actionButtons.value = buildActionButtons(status, isProfessional: isProfessional)
    }

    private func buildActionButtons(_ status: ListingViewModelStatus, isProfessional: Bool) -> [UIAction] {
        var actionButtons = [UIAction]()
        switch status {
        case .pending, .notAvailable, .otherSold, .otherSoldFree, .pendingAndFeatured:
            break
        case .available:
            actionButtons.append(UIAction(interface: .button(LGLocalizedString.productMarkAsSoldButton, .terciary),
                                          action: { [weak self] in self?.confirmToMarkAsSold() }))
        case .sold:
            actionButtons.append(UIAction(interface: .button(LGLocalizedString.productSellAgainButton, .secondary(fontSize: .big, withBorder: false)),
                                          action: { [weak self] in self?.confirmToMarkAsUnSold(free: false) }))
        case .otherAvailable, .otherAvailableFree:
            if isProfessional && featureFlags.allowCallsForProfessionals.isActive {
                actionButtons.append(UIAction(interface: .button(LGLocalizedString.productProfessionalChatButton, .secondary(fontSize: .big, withBorder: false)),
                                              action: { [weak self] in self?.openAskPhone() }))
            }
        case .availableFree:
            actionButtons.append(UIAction(interface: .button(LGLocalizedString.productMarkAsSoldFreeButton, .terciary),
                                          action: { [weak self] in self?.confirmToMarkAsSold() }))
        case .soldFree:
            actionButtons.append(UIAction(interface: .button(LGLocalizedString.productSellAgainFreeButton, .secondary(fontSize: .big, withBorder: false)),
                                          action: { [weak self] in self?.confirmToMarkAsUnSold(free: true) }))
        }

        return actionButtons
    }
}


// MARK: - Private actions

fileprivate extension ListingViewModel {

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
            navigator?.showProductFavoriteBubble(with: favoriteBubbleNotificationData())
        }
    }
  
    func favoriteBubbleNotificationData() -> BubbleNotificationData {
        let action = UIAction(interface: .text(LGLocalizedString.productBubbleFavoriteButton), action: { [weak self] in
            self?.sendMessage(type: .favoritedListing(LGLocalizedString.productFavoriteDirectMessage))
        }, accessibilityId: .bubbleButton)
        let data = BubbleNotificationData(tagGroup: ListingViewModel.bubbleTagGroup,
                                          text: LGLocalizedString.productBubbleFavoriteButton,
                                          infoText: LGLocalizedString.productBubbleFavoriteText,
                                          action: action,
                                          iconURL: nil,
                                          iconImage: UIImage(named: "user_placeholder"))
        return data
    }
    
    func selectBuyerToMarkAsSold(sourceRateBuyers: SourceRateBuyers) {
        guard let listingId = listing.value.objectId else { return }
        let trackingInfo = trackHelper.makeMarkAsSoldTrackingInfo(isShowingFeaturedStripe: isShowingFeaturedStripe.value)
        
        delegate?.vmShowLoading(nil)
        listingRepository.possibleBuyersOf(listingId: listingId) { [weak self] result in
            guard let strongSelf = self else { return }
            if let buyers = result.value, !buyers.isEmpty {
                strongSelf.delegate?.vmHideLoading(nil) {
                    guard let strongSelf = self else { return }
                    strongSelf.navigator?.selectBuyerToRate(source: .markAsSold,
                                                            buyers: buyers,
                                                            listingId: listingId,
                                                            sourceRateBuyers: sourceRateBuyers,
                                                            trackingInfo: trackingInfo)
                }
            } else {
                let message = strongSelf.listing.value.price.isFree ? LGLocalizedString.productMarkAsSoldFreeSuccessMessage : LGLocalizedString.productMarkAsSoldSuccessMessage
                strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
            }
        }
    }
    
    fileprivate func confirmToMarkAsSold() {
        guard isMine && status.value.isAvailable else { return }
        let free = status.value.isFree
        
        let okButton = LGLocalizedString.productMarkAsSoldAlertConfirm
        let title = free ? LGLocalizedString.productMarkAsGivenAwayAlertTitle: LGLocalizedString.productMarkAsSoldAlertTitle
        let message = free ? LGLocalizedString.productMarkAsGivenAwayAlertMessage : LGLocalizedString.productMarkAsSoldAlertMessage
        let cancel = LGLocalizedString.productMarkAsSoldAlertCancel

        var alertActions: [UIAction] = []
        let markAsSoldAction = UIAction(interface: .text(okButton),
                                        action: { [weak self] in
                                            self?.markAsSold()
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
            } else if let error = result.error {
                self?.trackHelper.trackReportError(error.reportError)
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
            if let _ = result.value, let listing = self?.listing.value {
                afterMessageAction = { [weak self] in
                    self?.navigator?.closeListingAfterDelete(listing)
                }
                self?.trackHelper.trackDeleteCompleted()
            } else if let _ = result.error {
                message = LGLocalizedString.productDeleteSendErrorGeneric
            }

            self?.delegate?.vmHideLoading(message, afterMessageCompletion: afterMessageAction)
        }
    }

    func markUnsold() {
        delegate?.vmShowLoading(nil)
        listingRepository.markAsUnsold(listing: listing.value) { [weak self] result in
            guard let strongSelf = self else { return }
            let message: String
            if let value = result.value {
                strongSelf.listing.value = value
                message = strongSelf.listing.value.price.isFree ? LGLocalizedString.productSellAgainFreeSuccessMessage : LGLocalizedString.productSellAgainSuccessMessage
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
                let messageViewSent = messageView.markAsSent()
                strongSelf.directChatMessages.replace(0, with: messageViewSent)
                let feedPosition = strongSelf.delegate?.trackingFeedPosition ?? .none
                let isFirstMessage = firstMessage && !strongSelf.alreadyTrackedFirstMessageSent
                let visitSource = strongSelf.visitSource(from: strongSelf.visitSource, isFirstMessage: isFirstMessage)
                strongSelf.trackHelper.trackMessageSent(isFirstMessage: isFirstMessage,
                                                        messageType: type,
                                                        isShowingFeaturedStripe: strongSelf.isShowingFeaturedStripe.value,
                                                        listingVisitSource: visitSource,
                                                        feedPosition: feedPosition)
                strongSelf.alreadyTrackedFirstMessageSent = true
            } else if let error = result.error {
                strongSelf.trackHelper.trackMessageSentError(messageType: type, isShowingFeaturedStripe: strongSelf.isShowingFeaturedStripe.value, error: error)
                switch error {
                case .forbidden:
                    strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.productChatDirectErrorBlockedUserMessage, completion: nil)
                case .network, .internalError, .notFound, .unauthorized, .tooManyRequests, .userNotVerified, .serverError:
                    strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.chatSendErrorGeneric, completion: nil)
                case let .wsChatError(chatRepositoryError):
                    switch chatRepositoryError {
                    case .userBlocked:
                        strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.productChatDirectErrorBlockedUserMessage, completion: nil)
                    case .internalError, .notAuthenticated, .userNotVerified, .network, .apiError:
                        strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.chatSendErrorGeneric, completion: nil)
                    case .differentCountry:
                        strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.chatSendErrorDifferentCountry, completion: nil)
                    }
                }
                //Removing in case of failure
                if let indexToRemove = strongSelf.directChatMessages.value.index(where: { $0.objectId == messageView.objectId }) {
                    strongSelf.directChatMessages.removeAtIndex(indexToRemove)
                }
            }
        }
    }
    
    fileprivate func visitSource(from originalSource: EventParameterListingVisitSource,
                                 isFirstMessage: Bool) -> EventParameterListingVisitSource {
        guard isFirstMessage,
            originalSource == .favourite,
            let origin = delegate?.listingOrigin else {
            return originalSource
        }
        var visitSource = originalSource
        let favourite = EventParameterListingVisitSource.favourite
        if origin == .inResponseToNextRequest {
            visitSource = favourite.next
        } else if origin == .inResponseToPreviousRequest {
             visitSource = favourite.previous
        }
        return visitSource
    }
}


// MARK: - Logged in checks

extension ListingViewModel {
    fileprivate func ifLoggedInRunActionElseOpenSignUp(from: EventParameterLoginSourceValue,
                                                       infoMessage: String,
                                                       action: @escaping () -> ()) {
        navigator?.openLoginIfNeededFromProductDetail(from: from, infoMessage: infoMessage, loggedInAction: action)
    }
}


// MARK: - SocialSharerDelegate

extension ListingViewModel: SocialSharerDelegate {
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

extension ListingViewModel: BumpInfoRequesterDelegate {
    func shopperFinishedProductsRequestForListingId(_ listingId: String?,
                                                    withProducts products: [PurchaseableProduct],
                                                    letgoItemId: String?,
                                                    storeProductId: String?,
                                                    typePage: EventParameterTypePage?) {
        guard let requestProdId = listingId, let currentProdId = listing.value.objectId,
            requestProdId == currentProdId else { return }
        guard let purchase = products.first else { return }

        bumpUpPurchaseableProduct = purchase

        createBumpeableBanner(forListingId: requestProdId,
                              withPrice: bumpUpPurchaseableProduct?.formattedCurrencyPrice,
                              letgoItemId: letgoItemId,
                              storeProductId: storeProductId,
                              bumpUpType: bumpUpType)
    }

    var bumpUpType: BumpUpType {
        if userIsSoftBlocked {
            return .hidden
        } else if featureFlags.bumpUpBoost.isActive && hasBumpInProgress {
            return .boost(boostBannerVisible: listingCanBeBoosted)
        } else {
            return .priced
        }
    }
}

extension ListingViewModel: PurchasesShopperDelegate {
    // Free Bump Up

    func freeBumpDidStart(typePage: EventParameterTypePage?) {
        trackBumpUpStarted(.free, type: .free, storeProductId: storeProductId, isPromotedBump: isPromotedBump,
                           typePage: typePage)
        delegate?.vmShowLoading(LGLocalizedString.bumpUpProcessingFreeText)
    }

    func freeBumpDidSucceed(withNetwork network: EventParameterShareNetwork, typePage: EventParameterTypePage?) {
        trackBumpUpCompleted(.free, type: .free, restoreRetriesCount: 0, network: network, transactionStatus: nil,
                             storeProductId: storeProductId, isPromotedBump: isPromotedBump, typePage: typePage)
        delegate?.vmHideLoading(LGLocalizedString.bumpUpFreeSuccess, afterMessageCompletion: { [weak self] in
            self?.delegate?.vmResetBumpUpBannerCountdown()
            self?.isShowingFeaturedStripe.value = true
        })
    }

    func freeBumpDidFail(withNetwork network: EventParameterShareNetwork, typePage: EventParameterTypePage?) {
        trackBumpUpFail(type: .free, transactionStatus: nil, storeProductId: storeProductId, typePage: typePage)
        delegate?.vmHideLoading(LGLocalizedString.bumpUpErrorBumpGeneric, afterMessageCompletion: nil)
    }


    // Paid Bump Up

    func pricedBumpDidStart(typePage: EventParameterTypePage?, isBoost: Bool) {
        let type: BumpUpType = isBoost ? .boost(boostBannerVisible: true) : .priced
        trackBumpUpStarted(.pay(price: bumpUpPurchaseableProduct?.formattedCurrencyPrice ?? ""), type: type,
                           storeProductId: storeProductId, isPromotedBump: isPromotedBump, typePage: typePage)
        delegate?.vmShowLoading(LGLocalizedString.bumpUpProcessingPricedText)
    }

    func paymentDidSucceed(paymentId: String, transactionStatus: EventParameterTransactionStatus) {
        trackMobilePaymentComplete(withPaymentId: paymentId, transactionStatus: transactionStatus)
    }

    func pricedBumpPaymentDidFail(withReason reason: String?, transactionStatus: EventParameterTransactionStatus) {
        trackMobilePaymentFail(withReason: reason, transactionStatus: transactionStatus)
        delegate?.vmHideLoading(LGLocalizedString.bumpUpErrorPaymentFailed, afterMessageCompletion: nil)
    }

    func pricedBumpDidSucceed(type: BumpUpType, restoreRetriesCount: Int, transactionStatus: EventParameterTransactionStatus,
                              typePage: EventParameterTypePage?, isBoost: Bool) {
        trackBumpUpCompleted(.pay(price: bumpUpPurchaseableProduct?.formattedCurrencyPrice ?? ""),
                             type: type,
                             restoreRetriesCount: restoreRetriesCount,
                             network: .notAvailable,
                             transactionStatus: transactionStatus,
                             storeProductId: storeProductId,
                             isPromotedBump: isPromotedBump,
                             typePage: typePage)

        delegate?.vmHideLoading(isBoost ? nil : LGLocalizedString.bumpUpPaySuccess, afterMessageCompletion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.vmResetBumpUpBannerCountdown()
            strongSelf.isShowingFeaturedStripe.value = true
            if isBoost {
                strongSelf.bumpUpBoostSucceeded()
            }
            if let currentBumpUpInfo = self?.bumpUpBannerInfo.value, strongSelf.featureFlags.bumpUpBoost.isActive {
                let newBannerInfo = BumpUpInfo(type: .boost(boostBannerVisible: false),
                                               timeSinceLastBump: 1,
                                               maxCountdown: currentBumpUpInfo.maxCountdown,
                                               price: currentBumpUpInfo.price,
                                               bannerInteractionBlock: currentBumpUpInfo.bannerInteractionBlock,
                                               buttonBlock: currentBumpUpInfo.buttonBlock)
                strongSelf.bumpUpBannerInfo.value = newBannerInfo
            } else {
                strongSelf.refreshBumpeableBanner()
            }
        })
    }

    func pricedBumpDidFail(type: BumpUpType, transactionStatus: EventParameterTransactionStatus,
                           typePage: EventParameterTypePage?, isBoost: Bool) {
        trackBumpUpFail(type: type, transactionStatus: transactionStatus, storeProductId: storeProductId,
                        typePage: typePage)
        delegate?.vmHideLoading(LGLocalizedString.bumpUpErrorBumpGeneric, afterMessageCompletion: { [weak self] in
            self?.refreshBumpeableBanner()
        })
    }


    // Restore Bump

    func restoreBumpDidStart() {
        trackBumpUpStarted(.pay(price: bumpUpPurchaseableProduct?.formattedCurrencyPrice ?? ""), type: .restore,
                           storeProductId: storeProductId, isPromotedBump: isPromotedBump, typePage: .listingDetail)
        delegate?.vmShowLoading(LGLocalizedString.bumpUpProcessingFreeText)
    }
}

// new item page
extension ListingViewModel {
    var isFavoritable: Bool { return !isMine }
}
