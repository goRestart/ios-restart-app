import CoreLocation
import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift
import RxCocoa
import LGComponents

final class ListingCardViewModel: BaseViewModel {
    weak var delegate: ListingViewModelDelegate?
    var navigator: ListingDetailNavigator?

    var isMine: Bool { return isMineRelay.value }
    var listing: Listing { return listingRelay.value }
    var seller: User? { return sellerRelay.value }
    var quickAnswers: [QuickAnswer] {
        guard !isMine else { return [] }
        let isFree = listingRelay.value.price.isFree && featureFlags.freePostingModeAllowed
        return QuickAnswer.quickAnswersForPeriscope(isFree: isFree)
    }
    var location: LGLocationCoordinates2D? { return productInfoRelay.value?.location }
    var showExactLocationOnMap: Bool { return showExactLocationOnMapRelay.value }
    var attributes: [ListingAttributeGridItem] { return productInfoRelay.value?.attributeGridItems ?? [] }
    private var myUserId: String? { return myUserRepository.myUser?.objectId }
    private var myUserName: String? { return myUserRepository.myUser?.name }
    let socialSharer: SocialSharer

    fileprivate let listingRelay: BehaviorRelay<Listing>
    fileprivate let isMineRelay: BehaviorRelay<Bool>
    fileprivate let actionButtonRelay = BehaviorRelay<UIAction?>(value: nil)
    fileprivate let sellerRelay = BehaviorRelay<User?>(value: nil)
    fileprivate let isFavoriteRelay = BehaviorRelay<Bool>(value: false)
    fileprivate let listingStatsRelay = BehaviorRelay<ListingStats?>(value: nil)
    fileprivate let showExactLocationOnMapRelay = BehaviorRelay<Bool>(value: false)
    fileprivate let productInfoRelay = BehaviorRelay<ListingVMProductInfo?>(value: nil)
    fileprivate let directChatEnabledRelay = BehaviorRelay<Bool>(value: false)
    fileprivate let userInfoRelay: BehaviorRelay<ListingVMUserInfo>
    fileprivate let statusRelay = BehaviorRelay<ListingViewModelStatus>(value: .pending)
    fileprivate let isReportedRelay = BehaviorRelay<Bool>(value: false)
    fileprivate let isInterestedRelay = BehaviorRelay<Bool>(value: false)
    fileprivate let bumpUpBannerInfoRelay = BehaviorRelay<BumpUpInfo?>(value: nil)
    fileprivate let isShowingFeaturedStripeRelay = BehaviorRelay<Bool>(value: false)
    fileprivate let socialMessage = BehaviorRelay<SocialMessage?>(value: nil)

    let directChatMessages = CollectionVariable<ChatViewMessage>([])
    private var isListingDetailsCompleted: Bool = false

    var navBarActions: [UIAction] {
        var navBarButtons = [UIAction]()
        if isMine {
            if statusRelay.value.isEditable && isListingDetailsCompleted {
                navBarButtons.append(buildEditAction())
            }
            navBarButtons.append(buildDeleteAction())
        } else {
            navBarButtons.append(buildReportAction())
        }
        navBarButtons.insert(buildShareAction(), at: navBarButtons.count - 1)
        return navBarButtons
    }

    fileprivate var isTransactionOpen: Bool = false

    fileprivate var timeSinceLastBump: TimeInterval = 0
    fileprivate var bumpMaxCountdown: TimeInterval = 0
    var availablePurchases: [BumpUpProductData] = []
    var purchaseInProgress: PurchaseableProduct?
    private var featurePurchaseTypeInProgress: FeaturePurchaseType = .bump
    private var isUpdatingBumpUpBanner: Bool = false
    private var letgoItemId: String?
    var storeProductId: String?
    private var userIsSoftBlocked: Bool = false
    private var bumpUpSource: BumpUpSource?
    var shouldExecuteBumpBannerAction: Bool = false

    fileprivate var alreadyTrackedFirstMessageSent: Bool = false
    fileprivate static let bubbleTagGroup = "favorite.bubble.group"


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
    fileprivate let visitSource: EventParameterListingVisitSource
    fileprivate let keyValueStorage: KeyValueStorageable

    var isPlayable: Bool {
        return listingRelay.value
            .media
            .map { $0.type }
            .reduce(false) { (result, next: MediaType) in return result || next == .video }
    }

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
        self.userInfoRelay = BehaviorRelay<ListingVMUserInfo>(value: ListingVMUserInfo(userListing: listing.user,
                                                                                  myUser: myUserRepository.myUser,
                                                                                  sellerBadge: .noBadge))
        self.listingRelay = BehaviorRelay<Listing>(value: listing)
        self.isMineRelay = BehaviorRelay(value: listing.isMine(myUserRepository: myUserRepository))
        self.disposeBag = DisposeBag()
        super.init()

        socialSharer.delegate = self
        setupRxBindings()
    }

    internal override func didBecomeActive(_ firstTime: Bool) {
        guard let listingId = listingRelay.value.objectId else { return }

        retrieveMoreDetails(listing: listingRelay.value)

        if isMine {
            sellerRelay.accept(myUserRepository.myUser)
            if featureFlags.alwaysShowBumpBannerWithLoading.isActive {
                bumpUpBannerInfoRelay.accept(BumpUpInfo.makeLoading())
            }
        } else if let userId = userInfoRelay.value.userId {
            userRepository.show(userId) { [weak self] result in
                guard let strongSelf = self else { return }
                if let value = result.value {
                    strongSelf.sellerRelay.accept(value)
                    strongSelf.sellerAverageUserRating = value.ratingAverage
                    strongSelf.userInfoRelay.accept(ListingVMUserInfo(userListing: strongSelf.listingRelay.value.user,
                                                                 myUser: strongSelf.myUserRepository.myUser,
                                                                 sellerBadge: value.reputationBadge))
                }
            }
        }

        listingRepository.incrementViews(listingId: listingId,
                                         visitSource: visitSource.rawValue,
                                         visitTimestamp: Date().millisecondsSince1970,
                                         completion: nil)

        if !relationRetrieved && myUserRepository.myUser != nil {
            refreshUserListingRelation()
        }

        if isMine && statusRelay.value.isSold {
            syncTransactions()
        }

        if listingStatsRelay.value == nil {
            listingRepository.retrieveStats(listingId: listingId) { [weak self] result in
                guard let stats = result.value else { return }
                self?.listingStatsRelay.accept(stats)
            }
        }

        purchasesShopper.delegate = self
        purchasesShopper.bumpInfoRequesterDelegate = self

        if bumpUpBannerInfoRelay.value == nil || bumpUpBannerInfoRelay.value?.type == .loading {
            refreshBumpeableBanner()
        }

        isInterestedRelay.accept(keyValueStorage.interestingListingIDs.contains(listingId))
    }

    func refreshUserListingRelation() {
        guard let listingId = listingRelay.value.objectId else { return }
        listingRepository.retrieveUserListingRelation(listingId) { [weak self] result in
            guard let value = result.value  else { return }
            self?.relationRetrieved = true
            self?.isFavoriteRelay.accept(value.isFavorited)
            self?.isReportedRelay.accept(value.isReported)
        }
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        bumpUpBannerInfoRelay.accept(nil)
    }

    func syncListing(_ completion: (() -> ())?) {
        guard let listingId = listingRelay.value.objectId else { return }
        listingRepository.retrieve(listingId) { [weak self] result in
            if let listing = result.value {
                self?.listingRelay.accept(listing)
            }
            completion?()
        }
    }

    func syncTransactions() {
        guard let listingId = listingRelay.value.objectId else { return }
        listingRepository.retrieveTransactionsOf(listingId: listingId) { [weak self] (result) in
            guard let transaction = result.value?.first else { return }
            self?.isTransactionOpen = !transaction.closed
        }
    }

    private func setupRxBindings() {
        if let productId = listingRelay.value.objectId {
            listingRepository
                .updateEvents(for: productId)
                .bind { [weak self] listing in
                self?.listingRelay.accept(listing)
            }.disposed(by: disposeBag)
        }

        let statusObs = statusRelay.asObservable().share()
        let sellerObs = sellerRelay.asObservable()
        let listingActionsObs = Observable.combineLatest(statusObs,
                                                         sellerObs.map { $0?.isProfessional ?? false }) { ($0, $1) }.share()

        listingActionsObs
            .asDriver(onErrorJustReturn: (.pending, false))
            .map { [unowned self] in self.buildActionButton($0.0, isProfessional: $0.1) }
            .drive(actionButtonRelay)
            .disposed(by: disposeBag)

        listingActionsObs
            .bind { [weak self] (status, isPro) in
            guard let strongSelf = self else { return }
            strongSelf.directChatEnabledRelay.accept(status.directChatsAvailable && !isPro)
        }.disposed(by: disposeBag)

        // bumpeable listing check
        statusObs
            .skip(1) // initial
            .bind { [weak self] status in
            guard let strongSelf = self else  { return }
            guard strongSelf.active else { return }
            if status.shouldRefreshBumpBanner {
                self?.refreshBumpeableBanner()
            } else {
                self?.bumpUpBannerInfoRelay.accept(nil)
            }
        }.disposed(by: disposeBag)

        listingRelay
            .asObservable()
            .subscribeNext { [weak self] listing in
                guard let strongSelf = self else { return }
                strongSelf.trackHelper.listing = listing
                let isMine = listing.isMine(myUserRepository: strongSelf.myUserRepository)
                strongSelf.statusRelay.accept(ListingViewModelStatus(listing: listing, isMine: isMine, featureFlags: strongSelf.featureFlags))

                strongSelf.isShowingFeaturedStripeRelay.accept(listing.shouldShowFeaturedStripe && !strongSelf.statusRelay.value.shouldShowStatus)

                strongSelf.socialMessage.accept(ListingSocialMessage(listing: listing,
                                                                fallbackToStore: false,
                                                                myUserId: strongSelf.myUserId,
                                                                myUserName: strongSelf.myUserName))
                let productInfo = ListingVMProductInfo(listing: listing,
                                                       isAutoTranslated: listing.isTitleAutoTranslated(strongSelf.countryHelper),
                                                       distance: strongSelf.distanceString(listing),
                                                       freeModeAllowed: strongSelf.featureFlags.freePostingModeAllowed,
                                                       postingFlowType: strongSelf.featureFlags.postingFlowType)
                strongSelf.productInfoRelay.accept(productInfo)
            }.disposed(by: disposeBag)

        myUserRepository.rx_myUser
            .bind { [weak self] _ in
            self?.refreshStatus()
            }.disposed(by: disposeBag)

        sellerObs
            .map { [weak self] in ($0?.isProfessional ?? false) &&
                (self?.featureFlags.showExactLocationForPros ?? false) }
            .asDriver(onErrorJustReturn: false)
            .drive(showExactLocationOnMapRelay)
            .disposed(by: disposeBag)

        bumpUpBannerInfoRelay
            .asObservable()
            .bind { [weak self] bumpUpBannerInfo in
            guard let strongSelf = self else { return }
            guard let bumpInfo = bumpUpBannerInfo,
                bumpInfo.type != .loading,
                strongSelf.shouldExecuteBumpBannerAction else { return }

            bumpInfo.bannerInteractionBlock(bumpInfo.timeSinceLastBump)
            strongSelf.shouldExecuteBumpBannerAction = false
            }.disposed(by: disposeBag)
    }

    private func distanceString(_ listing: Listing) -> String? {
        guard let userLocation = locationManager.currentLocation?.location else { return nil }
        let distance = listing.location.distanceTo(userLocation)
        let distanceString = String(format: "%0.1f %@", arguments: [distance, DistanceType.systemDistanceType().rawValue])
        return R.Strings.productDistanceXFromYou(distanceString)
    }

    private func refreshStatus() {
        statusRelay.accept(ListingViewModelStatus(listing: listingRelay.value, isMine: isMine, featureFlags: featureFlags))
    }

    private func retrieveMoreDetails(listing: Listing) {
        guard let listingId = listing.objectId else {
            isListingDetailsCompleted = true
            return
        }

        let retrieveCompletion: ListingCompletion? = { [weak self] (result) in
            guard let updatedListing = result.value else { return }
            self?.listingRelay.accept(updatedListing)
            self?.isListingDetailsCompleted = true
        }

        if listing.isRealEstateWithEmptyAttributes {
            listingRepository.retrieveRealEstate(listingId, completion: retrieveCompletion)
        } else if listing.isServiceWithEmptyAttributes {
            listingRepository.retrieveService(listingId, completion: retrieveCompletion)
        } else if listing.isCarWithEmptyAttributes {
            listingRepository.retrieveCar(listingId, completion: retrieveCompletion)
        } else {
            isListingDetailsCompleted = true
        }
    }

    func refreshBumpeableBanner() {
        guard statusRelay.value.shouldRefreshBumpBanner else {
            bumpUpBannerInfoRelay.accept(nil)
            return
        }
        guard let listingId = listingRelay.value.objectId, !isUpdatingBumpUpBanner, isMine else { return }

        let isBumpUpPending = purchasesShopper.isBumpUpPending(forListingId: listingId)

        if isBumpUpPending {
            createBumpeableBanner(forListingId: listingId, purchases: [], bumpUpType: .restore, typePage: .listingDetail)
        } else if let recentBumpInfo = purchasesShopper.timeSinceRecentBumpFor(listingId: listingId) {
            createBumpeableBannerForRecent(listingId: listingId,
                                           bumpUpType: recentBumpInfo.bumpUpType,
                                           withTime: recentBumpInfo.timeDifference,
                                           maxCountdown: recentBumpInfo.maxCountdown)
        } else {
            isUpdatingBumpUpBanner = true
            if featureFlags.multiDayBumpUp.isActive {
                // new call
                retrieveAvailablePurchasesFor(listingId: listingId)
            } else {
                // old call
                retrieveBumpeableListingInfoFor(listingId: listingId)
            }
        }
    }

    private func retrieveBumpeableListingInfoFor(listingId: String) {
        monetizationRepository.retrieveBumpeableListingInfo(
            listingId: listingId,
            completion: { [weak self] result in
                guard let strongSelf = self else { return }
                let parameterTypePage = strongSelf.getParameterTypePage()
                strongSelf.isUpdatingBumpUpBanner = false
                guard let bumpeableProduct = result.value else {
                    strongSelf.bumpUpBannerInfoRelay.accept(nil)
                    return
                }
                strongSelf.timeSinceLastBump = bumpeableProduct.timeSinceLastBump
                strongSelf.bumpMaxCountdown = bumpeableProduct.maxCountdown
                let paymentItems = bumpeableProduct.paymentItems.filter { $0.provider == .apple }
                let hiddenItems = bumpeableProduct.paymentItems.filter { $0.provider == .hidden }
                if !paymentItems.isEmpty {
                    strongSelf.userIsSoftBlocked = false
                    // will be considered bumpeable ONCE WE GOT THE PRICES of the products, not before.
                    strongSelf.letgoItemId = paymentItems.first?.itemId
                    strongSelf.storeProductId = paymentItems.first?.providerItemId
                    // if "letgoItemId" is nil, the banner creation will fail, so we check this here to avoid
                    // a useless request to apple
                    if let letgoItemId = strongSelf.letgoItemId, let providerItemId = strongSelf.storeProductId {
                        strongSelf.purchasesShopper.productsRequestStartForListingId(listingId,
                                                                                     letgoItemId: letgoItemId,
                                                                                     providerItemId: providerItemId,
                                                                                     maxCountdown: bumpeableProduct.maxCountdown,
                                                                                     timeSinceLastBump: bumpeableProduct.timeSinceLastBump,
                                                                                     typePage: parameterTypePage)
                    }
                } else if !hiddenItems.isEmpty {
                    strongSelf.userIsSoftBlocked = true
                    // for hidden items we follow THE SAME FLOW we do for PAID items
                    strongSelf.letgoItemId = hiddenItems.first?.itemId
                    strongSelf.storeProductId = hiddenItems.first?.providerItemId
                    // if "letgoItemId" is nil, the banner creation will fail, so we check this here to avoid
                    // a useless request to apple
                    if let letgoItemId = strongSelf.letgoItemId, let providerItemId = strongSelf.storeProductId {
                        strongSelf.purchasesShopper.productsRequestStartForListingId(listingId,
                                                                                     letgoItemId: letgoItemId,
                                                                                     providerItemId: providerItemId,
                                                                                     maxCountdown: bumpeableProduct.maxCountdown,
                                                                                     timeSinceLastBump: bumpeableProduct.timeSinceLastBump,
                                                                                     typePage: parameterTypePage)
                    }
                } else {
                    strongSelf.bumpUpBannerInfoRelay.accept(nil)
                }
        })
    }

    private func retrieveAvailablePurchasesFor(listingId: String) {
        monetizationRepository.retrieveAvailablePurchasesFor(listingIds: [listingId]) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isUpdatingBumpUpBanner = false
            guard let availableFeaturePurchases = result.value,
                let listingAvailablePurchases = availableFeaturePurchases
                    .filter(
                        { $0.listingId == strongSelf.listingRelay.value.objectId }
                    ).first else {
                        // no banner
                    strongSelf.bumpUpBannerInfoRelay.accept(nil)
                    return
            }
            let availablePurchases = listingAvailablePurchases.purchases.availablePurchases
            strongSelf.availableMultiDayPurchases = availablePurchases

            if !availablePurchases.isEmpty {
                if let featureInProgress = listingAvailablePurchases.purchases.featureInProgress {
                    strongSelf.timeSinceLastBump = featureInProgress.secondsSinceLastFeature
                    strongSelf.bumpMaxCountdown = featureInProgress.featureDuration
                }

                let paymentPurchases = availablePurchases.filter { $0.provider == .apple }
                let hiddenPurchases = availablePurchases.filter { $0.provider == .hidden }
                strongSelf.userIsSoftBlocked = !hiddenPurchases.isEmpty
                if !paymentPurchases.isEmpty {
                    // will be considered bumpeable ONCE WE GOT THE PRICES of the products, not before.
                    strongSelf.purchasesShopper.requestProviderForPurchases(purchases: paymentPurchases,
                                                                            listingId: listingId,
                                                                            typePage: strongSelf.getParameterTypePage())
                } else if !hiddenPurchases.isEmpty {
                    strongSelf.createBannerForSoftBlockedUserFor(listingId: listingAvailablePurchases.listingId)
                }
            } else if let featureInProgress = listingAvailablePurchases.purchases.featureInProgress {
                // 3 or 7 days bump in progress
                strongSelf.createBannerForOngoingMultiDay(featureInProgress: featureInProgress,
                                                          forListingId: listingId)
            } else {
                // no banner
                strongSelf.bumpUpBannerInfoRelay.accept(nil)
            }
        }
    }

    private func createBannerForSoftBlockedUserFor(listingId: String) {
        createBumpeableBanner(forListingId: listingId,
                              purchases: [],
                              bumpUpType: .hidden,
                              typePage: getParameterTypePage())
    }

    private func createBannerForOngoingMultiDay(featureInProgress: FeatureInProgress,
                                                forListingId listingId: String) {
        timeSinceLastBump = featureInProgress.secondsSinceLastFeature
        bumpMaxCountdown = featureInProgress.featureDuration

        var bumpType: BumpUpType = .boost(boostBannerVisible: false)
        if let purchaseType = featureInProgress.purchaseType {
            bumpType = .ongoingBump(featurePurchaseType: purchaseType)
        }

        createBumpeableBanner(forListingId: listingId,
                              purchases: [],
                              bumpUpType: bumpType,
                              typePage: getParameterTypePage())
    }


    private func getParameterTypePage() -> EventParameterTypePage {
        guard let bumpUpSource = self.bumpUpSource,
            let typePageParameter = bumpUpSource.typePageParameter else { return .listingDetail }
        return typePageParameter
    }

    fileprivate func createBumpeableBanner(forListingId listingId: String,
                                           purchases: [BumpUpProductData],
                                           bumpUpType: BumpUpType,
                                           typePage: EventParameterTypePage) {
        let actualTypePage = shouldExecuteBumpBannerAction ? typePage : .listingDetail
        var bannerInteractionBlock: (TimeInterval?) -> Void
        var buttonBlock: (TimeInterval?) -> Void
        switch bumpUpType {
        case .free:
            return
        case .priced:
            guard purchases.hasPaymentIds else { return }
            bannerInteractionBlock = { [weak self] _ in
                guard let _ = self?.listingRelay.value else { return }
                self?.openPricedBumpUpView(purchases: purchases,
                                           typePage: actualTypePage)
            }
            buttonBlock = bannerInteractionBlock
        case .boost:
            guard purchases.hasPaymentIds else { return }
            bannerInteractionBlock = { [weak self] timeSinceLastBump in
                guard let _ = self?.listingRelay.value else { return }
                self?.openBoostBumpUpView(purchases: purchases,
                                          typePage: actualTypePage,
                                          timeSinceLastBump: timeSinceLastBump)
            }
            buttonBlock = bannerInteractionBlock
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
                let contactUsInterface = UIActionInterface.button(R.Strings.bumpUpNotAllowedAlertContactButton,
                                                                  .primary(fontSize: .medium))
                let contactUsAction: UIAction = UIAction(interface: contactUsInterface,
                                                         action: { [weak self] in
                                                            self?.bumpUpHiddenProductContactUs()
                    },
                                                         accessibility: AccessibilityId.bumpUpHiddenListingAlertContactButton)

                let cancelInterface = UIActionInterface.button(R.Strings.commonCancel,
                                                               .secondary(fontSize: .medium, withBorder: true))
                let cancelAction: UIAction = UIAction(interface: cancelInterface,
                                                      action: {},
                                                      accessibility: AccessibilityId.bumpUpHiddenListingAlertCancelButton)


                self?.navigator?.showBumpUpNotAvailableAlertWithTitle(title: R.Strings.commonErrorTitle,
                                                                      text: R.Strings.bumpUpNotAllowedAlertText,
                                                                      alertType: .plainAlert,
                                                                      buttonsLayout: .vertical,
                                                                      actions: [contactUsAction, cancelAction])
            }
            bannerInteractionBlock = hiddenBlock
            buttonBlock = hiddenBlock
        case .loading:
            bannerInteractionBlock = { _ in }
            buttonBlock = { _ in }
        case .ongoingBump(let featurePurchaseType):
            bannerInteractionBlock = { [weak self] _ in
                guard let strongSelf = self else { return }
                self?.openMultiDayInfoBumpUpView(featurePurchaseType: featurePurchaseType,
                                                 typePage: actualTypePage,
                                                 timeSinceLastBump: strongSelf.timeSinceLastBump,
                                                 maxCountdown: strongSelf.bumpMaxCountdown)
            }
            buttonBlock = bannerInteractionBlock
        }

        bumpUpBannerInfoRelay.accept(BumpUpInfo(type: bumpUpType,
                                            timeSinceLastBump: timeSinceLastBump,
                                            maxCountdown: bumpMaxCountdown,
                                            bannerInteractionBlock: bannerInteractionBlock,
                                            buttonBlock: buttonBlock))
    }

    fileprivate func createBumpeableBannerForRecent(listingId: String,
                                                    bumpUpType: BumpUpType,
                                                    withTime: TimeInterval,
                                                    maxCountdown: TimeInterval) {
        var updatedBumpUpType = bumpUpType
        var updatedBlock: (TimeInterval?) -> Void = { _ in }
        switch bumpUpType {
        case .boost, .priced:
            updatedBumpUpType = .boost(boostBannerVisible: false)
        case .ongoingBump(let featurePurchaseType):
            updatedBlock = { [weak self] _ in
                guard let _ = self?.listingRelay.value else { return }
                self?.openMultiDayInfoBumpUpView(featurePurchaseType: featurePurchaseType,
                                                 typePage: .listingDetail,
                                                 timeSinceLastBump: withTime,
                                                 maxCountdown: maxCountdown)
            }
        case .free, .hidden, .loading, .restore:
            break
        }

        bumpUpBannerInfoRelay.accept(BumpUpInfo(type: updatedBumpUpType,
                                            timeSinceLastBump: withTime,
                                            maxCountdown: maxCountdown,
                                            bannerInteractionBlock: updatedBlock,
                                            buttonBlock: updatedBlock))
    }

    func bumpUpHiddenProductContactUs() {
        trackBumpUpNotAllowedContactUs(reason: .notAllowedInternal)
        navigator?.openContactUs(forListing: listingRelay.value, contactUstype: .bumpUpNotAllowed)
    }

    func showBumpUpView(purchases: [BumpUpProductData],
                        maxCountdown: TimeInterval,
                        bumpUpType: BumpUpType?,
                        bumpUpSource: BumpUpSource?,
                        typePage: EventParameterTypePage?) {
        self.bumpUpSource = bumpUpSource
        self.bumpMaxCountdown = maxCountdown
        guard let bumpUpType = bumpUpType, !purchases.isEmpty else { return }

        switch bumpUpType {
        case .priced, .boost:
            guard purchases.hasPaymentIds else { return }
            openPricedBumpUpView(purchases: purchases,
                                 typePage: typePage)
        case .free, .hidden, .restore, .loading:
            break
        case .ongoingBump(let featurePurchaseType):
            openMultiDayInfoBumpUpView(featurePurchaseType: featurePurchaseType,
                                       typePage: typePage,
                                       timeSinceLastBump: timeSinceLastBump,
                                       maxCountdown: bumpMaxCountdown)
        }
    }

    func openPricedBumpUpView(purchases: [BumpUpProductData],
                              typePage: EventParameterTypePage?) {
        if featureFlags.multiDayBumpUp.isActive {
            navigator?.openMultiDayBumpUp(forListing: listingRelay.value,
                                          purchases: purchases,
                                          typePage: typePage,
                                          maxCountdown: bumpMaxCountdown)
        } else {
            navigator?.openPayBumpUp(forListing: listingRelay.value,
                                     purchases: purchases,
                                     typePage: typePage,
                                     maxCountdown: bumpMaxCountdown)
        }
    }

    func openBoostBumpUpView(purchases: [BumpUpProductData],
                             typePage: EventParameterTypePage?,
                             timeSinceLastBump: TimeInterval?) {
        navigator?.openBumpUpBoost(forListing: listingRelay.value,
                                   purchases: purchases,
                                   typePage: typePage,
                                   timeSinceLastBump: timeSinceLastBump ?? self.timeSinceLastBump,
                                   maxCountdown: bumpMaxCountdown)
    }

    func openMultiDayInfoBumpUpView(featurePurchaseType: FeaturePurchaseType,
                                    typePage: EventParameterTypePage?,
                                    timeSinceLastBump: TimeInterval,
                                    maxCountdown: TimeInterval) {
        navigator?.openMultiDayInfoBumpUp(forListing: listingRelay.value,
                                          featurePurchaseType: featurePurchaseType,
                                          typePage: typePage,
                                          timeSinceLastBump: timeSinceLastBump,
                                          maxCountdown: maxCountdown)
    }

    func bumpUpBoostSucceeded() {
        navigator?.showBumpUpBoostSucceededAlert()
    }

    private var listingCanBeBoosted: Bool {
        if featureFlags.multiDayBumpUp.isActive {
            let boostPurchaseIsAvailable = !(availableMultiDayPurchases.filter { $0.purchaseType == .boost }.isEmpty)
            return boostPurchaseIsAvailable && timeSinceLastBump > BumpUpBanner.boostBannerUIUpdateThreshold
        }
        return timeSinceLastBump > BumpUpBanner.boostBannerUIUpdateThreshold
    }
    private var availableMultiDayPurchases: [FeaturePurchase] = []

    private var hasBumpInProgress: Bool {
        return timeSinceLastBump > 0
    }
}


// MARK: - Public actions

extension ListingCardViewModel {

    func openProductOwnerProfile() {
        let data = UserDetailData.userAPI(user: LocalUser(userListing: listingRelay.value.user), source: .listingDetail)
        navigator?.openUser(data)
    }

    func editListing() {
        navigator?.editListing(listingRelay.value,
                               purchases: availablePurchases,
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
        guard let seller = sellerRelay.value else { return }
        let source: EventParameterTypePage = .listingDetail
        trackHelper.trackChatWithSeller(source)
        navigator?.openListingChat(listingRelay.value, source: .listingDetail, interlocutor: seller)
    }

    func sendDirectMessage(_ text: String, isDefaultText: Bool, trackingInfo: SectionedFeedChatTrackingInfo?) {
        ifLoggedInRunActionElseOpenSignUp(from: .directChat, infoMessage: R.Strings.chatLoginPopupText) { [weak self] in
            if isDefaultText {
                self?.sendMessage(type: .periscopeDirect(text), sectionedFeedChatTrackingInfo: trackingInfo)
            } else {
                self?.sendMessage(type: .text(text), sectionedFeedChatTrackingInfo: trackingInfo)
            }
        }
    }

    func sendQuickAnswer(quickAnswer: QuickAnswer, trackingInfo: SectionedFeedChatTrackingInfo?) {
        ifLoggedInRunActionElseOpenSignUp(from: .directQuickAnswer, infoMessage: R.Strings.chatLoginPopupText) { [weak self] in
            self?.sendMessage(type: .quickAnswer(quickAnswer), sectionedFeedChatTrackingInfo: trackingInfo)
        }
    }

    func sendInterested(trackingInfo: SectionedFeedChatTrackingInfo?) {
        ifLoggedInRunActionElseOpenSignUp(from: .directQuickAnswer, infoMessage: R.Strings.chatLoginPopupText) { [weak self] in
            self?.sendMessage(type: .interested(QuickAnswer.interested.textToReply), sectionedFeedChatTrackingInfo: trackingInfo)
        }
    }

    func switchFavorite() {
        ifLoggedInRunActionElseOpenSignUp(from: .favourite, infoMessage: R.Strings.productFavoriteLoginPopupText) {
            [weak self] in self?.switchFavoriteAction()
        }
    }

    func titleURLPressed(_ url: URL) {
        showItemHiddenIfNeededFor(url: url)
    }

    func descriptionURLPressed(_ url: URL) {
        showItemHiddenIfNeededFor(url: url)
    }

    func markAsSold() {
        guard myUserId == listingRelay.value.user.objectId else { return }
        delegate?.vmShowLoading(nil)
        listingRepository.markAsSold(listing: listingRelay.value) { [weak self] result in
            guard let strongSelf = self else { return }

            if let value = result.value {
                strongSelf.listingRelay.accept(value)
                strongSelf.trackHelper.trackMarkSoldCompleted(isShowingFeaturedStripe: strongSelf.isShowingFeaturedStripeRelay.value)
                strongSelf.selectBuyerToMarkAsSold(sourceRateBuyers: .markAsSold)
            } else {
                let message = R.Strings.productMarkAsSoldErrorGeneric
                strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
            }
        }
    }

    func openAskPhone() {
        ifLoggedInRunActionElseOpenSignUp(from: .chatProUser, infoMessage: R.Strings.chatLoginPopupText) { [weak self] in
            guard let strongSelf = self else  { return }
            if let listingId = strongSelf.listingRelay.value.objectId,
                strongSelf.keyValueStorage.proSellerAlreadySentPhoneInChat.contains(listingId) {
                strongSelf.chatWithSeller()
            } else {
                strongSelf.navigator?.openAskPhoneFor(listing: strongSelf.listingRelay.value,
                                                      interlocutor: strongSelf.sellerRelay.value)
            }
        }
    }
}


// MARK: - Helper Navbar

extension ListingCardViewModel {

    private func buildFavoriteNavBarAction() -> UIAction {
        let icon = (isFavoriteRelay.value ? R.Asset.IconsButtons.navbarFavOn.image : R.Asset.IconsButtons.navbarFavOff.image)
            .withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in
            self?.switchFavorite()
            }, accessibility: AccessibilityId.listingCarouselNavBarFavoriteButton)
    }

    private func buildEditNavBarAction() -> UIAction {
        let icon = R.Asset.IconsButtons.navbarEdit.image.withRenderingMode(.alwaysOriginal)
        return UIAction(interface: .image(icon, nil), action: { [weak self] in
            self?.editListing()
            }, accessibility: AccessibilityId.listingCarouselNavBarEditButton)
    }

    private func buildShareNavBarAction() -> UIAction {
        if DeviceFamily.current.isWiderOrEqualThan(.iPhone6) {
            return UIAction(interface: .textImage(R.Strings.productShareNavbarButton, R.Asset.IconsButtons.icShare.image), action: { [weak self] in
                self?.shareProduct()
                }, accessibility: AccessibilityId.listingCarouselNavBarShareButton)
        } else {
            return UIAction(interface: .text(R.Strings.productShareNavbarButton), action: { [weak self] in
                self?.shareProduct()
                }, accessibility: AccessibilityId.listingCarouselNavBarShareButton)
        }
    }

    private func buildEditAction() -> UIAction {
        return UIAction(interface: .text(R.Strings.productOptionEdit), action: { [weak self] in
            self?.editListing()
            }, accessibility: AccessibilityId.listingCarouselNavBarEditButton)
    }

    private func buildShareAction() -> UIAction {
        return UIAction(interface: .text(R.Strings.productOptionShare), action: { [weak self] in
            self?.shareProduct()
            }, accessibility: AccessibilityId.listingCarouselNavBarShareButton)
    }

    private func buildReportAction() -> UIAction {
        let title = R.Strings.productReportProductButton
        return UIAction(interface: .text(title), action: { [weak self] in self?.confirmToReportProduct() } )
    }

    fileprivate func confirmToReportProduct() {
        ifLoggedInRunActionElseOpenSignUp(from: .reportFraud, infoMessage: R.Strings.productReportLoginPopupText) {
            [weak self] () -> () in
            guard let strongSelf = self, !strongSelf.isMine else { return }

            let alertOKAction = UIAction(interface: .text(R.Strings.commonYes),
                                         action: { [weak self] in
                                            self?.report()
            })
            strongSelf.delegate?.vmShowAlert(R.Strings.productReportConfirmTitle,
                                             message: R.Strings.productReportConfirmMessage,
                                             cancelLabel: R.Strings.commonNo,
                                             actions: [alertOKAction])
        }
    }

    private func buildDeleteAction() -> UIAction {
        let title = R.Strings.productDeleteConfirmTitle
        return UIAction(interface: .text(title), action: { [weak self] in
            guard let strongSelf = self else { return }

            let message: String
            var alertActions = [UIAction]()
            if strongSelf.suggestMarkSoldWhenDeleting {
                message = R.Strings.productDeleteConfirmMessage

                let soldAction = UIAction(interface: .text(R.Strings.productDeleteConfirmSoldButton),
                                          action: { [weak self] in
                                            self?.confirmToMarkAsSold()
                })
                alertActions.append(soldAction)

                let deleteAction = UIAction(interface: .text(R.Strings.productDeleteConfirmOkButton),
                                            action: { [weak self] in
                                                self?.delete()
                })
                alertActions.append(deleteAction)
            } else {
                message = R.Strings.productDeleteSoldConfirmMessage

                let deleteAction = UIAction(interface: .text(R.Strings.commonOk),
                                            action: { [weak self] in
                                                self?.delete()
                })
                alertActions.append(deleteAction)
            }

            strongSelf.delegate?.vmShowAlert(R.Strings.productDeleteConfirmTitle, message: message,
                                             cancelLabel: R.Strings.productDeleteConfirmCancelButton,
                                             actions: alertActions)
        })
    }

    private var socialShareMessage: SocialMessage {
        return ListingSocialMessage(listing: listingRelay.value,
                                    fallbackToStore: false,
                                    myUserId: myUserId,
                                    myUserName: myUserName)
    }

    private var suggestMarkSoldWhenDeleting: Bool {
        switch listingRelay.value.status {
        case .pending, .discarded, .sold, .soldOld, .deleted:
            return false
        case .approved:
            return true
        }
    }
}


// MARK: - Helper Action buttons

extension ListingCardViewModel {

    private func buildActionButton(_ status: ListingViewModelStatus, isProfessional: Bool) -> UIAction? {
        switch status {
        case .pending, .notAvailable, .otherSold, .otherSoldFree, .pendingAndFeatured:
            break
        case .available:
            return UIAction(interface: .button(R.Strings.productMarkAsSoldButton, .terciary),
                            action: { [weak self] in self?.confirmToMarkAsSold() })
        case .sold:
            return UIAction(interface: .button(R.Strings.productSellAgainButton, .secondary(fontSize: .big, withBorder: false)),
                                          action: { [weak self] in self?.confirmToMarkAsUnSold(free: false) })
        case .otherAvailable, .otherAvailableFree:
            if isProfessional {
                let style: ButtonStyle = .secondary(fontSize: .big, withBorder: featureFlags.deckItemPage.isActive)
                return UIAction(interface: .button(R.Strings.productProfessionalChatButton, style),
                                              action: { [weak self] in self?.openAskPhone() })
            }
            break
        case .availableFree:
            return UIAction(interface: .button(R.Strings.productMarkAsSoldFreeButton, .terciary),
                                          action: { [weak self] in self?.confirmToMarkAsSold() })
        case .soldFree:
           return UIAction(interface: .button(R.Strings.productSellAgainFreeButton,
                                                             .secondary(fontSize: .big, withBorder: false)),
                                          action: { [weak self] in self?.confirmToMarkAsUnSold(free: true) })
        }
        return nil
    }
}


// MARK: - Private actions

fileprivate extension ListingCardViewModel {

    func showItemHiddenIfNeededFor(url: URL) {
        guard let _ = TextHiddenTags(fromURL: url) else { return }

        let okAction = UIAction(interface: .button(R.Strings.commonOk, .primary(fontSize: .big)), action: {})
        delegate?.vmShowAlertWithTitle(R.Strings.hiddenTextAlertTitle,
                                       text: R.Strings.hiddenTextAlertDescription,
                                       alertType: .iconAlert(icon: R.Asset.IconsButtons.icSafetyTipsBig.image),
                                       actions: [okAction])
    }

    func switchFavoriteAction() {
        let currentFavoriteValue = isFavoriteRelay.value
        isFavoriteRelay.accept(!currentFavoriteValue)
        if currentFavoriteValue {
            listingRepository.deleteFavorite(listing: listingRelay.value) { [weak self] result in
                guard let strongSelf = self else { return }
                if let _ = result.error {
                    strongSelf.isFavoriteRelay.accept(currentFavoriteValue)
                }
            }
        } else {
            listingRepository.saveFavorite(listing: listingRelay.value) { [weak self] result in
                guard let strongSelf = self else { return }
                if let _ = result.value {
                    self?.trackHelper.trackSaveFavoriteCompleted(strongSelf.isShowingFeaturedStripeRelay.value)

                    self?.navigator?.openAppRating(.favorite)
                } else {
                    strongSelf.isFavoriteRelay.accept(currentFavoriteValue)
                }
            }
            navigator?.showProductFavoriteBubble(with: favoriteBubbleNotificationData())
        }
    }

    func favoriteBubbleNotificationData() -> BubbleNotificationData {
        let action = UIAction(interface: .text(R.Strings.productBubbleFavoriteButton), action: { [weak self] in
            self?.sendMessage(type: .favoritedListing(R.Strings.productFavoriteDirectMessage),
                              sectionedFeedChatTrackingInfo: nil)
            }, accessibility: AccessibilityId.bubbleButton)
        let data = BubbleNotificationData(tagGroup: ListingCardViewModel.bubbleTagGroup,
                                          text: R.Strings.productBubbleFavoriteButton,
                                          infoText: R.Strings.productBubbleFavoriteText,
                                          action: action,
                                          iconURL: nil,
                                          iconImage: R.Asset.IconsButtons.userPlaceholder.image)
        return data
    }

    func selectBuyerToMarkAsSold(sourceRateBuyers: SourceRateBuyers) {
        guard let listingId = listingRelay.value.objectId else { return }
        let trackingInfo = trackHelper.makeMarkAsSoldTrackingInfo(isShowingFeaturedStripe: isShowingFeaturedStripeRelay.value)

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
                let message = strongSelf.listingRelay.value.price.isFree ? R.Strings.productMarkAsSoldFreeSuccessMessage : R.Strings.productMarkAsSoldSuccessMessage
                strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: { [weak self] in
                    self?.navigator?.openPostAnotherListing()
                })
            }
        }
    }

    fileprivate func confirmToMarkAsSold() {
        guard isMine && statusRelay.value.isAvailable else { return }
        let free = statusRelay.value.isFree

        let okButton = R.Strings.productMarkAsSoldAlertConfirm
        let title = free ? R.Strings.productMarkAsGivenAwayAlertTitle: R.Strings.productMarkAsSoldAlertTitle
        let message = free ? R.Strings.productMarkAsGivenAwayAlertMessage : R.Strings.productMarkAsSoldAlertMessage
        let cancel = R.Strings.productMarkAsSoldAlertCancel

        var alertActions: [UIAction] = []
        let markAsSoldAction = UIAction(interface: .text(okButton),
                                        action: { [weak self] in
                                            self?.markAsSold()
        })
        alertActions.append(markAsSoldAction)
        delegate?.vmShowAlert(title, message: message, cancelLabel: cancel, actions: alertActions)
    }

    func confirmToMarkAsUnSold(free: Bool) {
        let okButton = free ? R.Strings.productSellAgainFreeConfirmOkButton : R.Strings.productSellAgainConfirmOkButton
        let title = free ? R.Strings.productSellAgainFreeConfirmTitle : R.Strings.productSellAgainConfirmTitle
        let message = free ? R.Strings.productSellAgainFreeConfirmMessage : R.Strings.productSellAgainConfirmMessage
        let cancel = free ? R.Strings.productSellAgainFreeConfirmCancelButton : R.Strings.productSellAgainConfirmCancelButton

        var alertActions: [UIAction] = []
        let sellAgainAction = UIAction(interface: .text(okButton),
                                       action: { [weak self] in
                                        self?.markUnsold()
        })
        alertActions.append(sellAgainAction)
        delegate?.vmShowAlert(title, message: message, cancelLabel: cancel, actions: alertActions)
    }

    func report() {
        guard let productId = listingRelay.value.objectId else { return }
        if isReportedRelay.value {
            delegate?.vmHideLoading(R.Strings.productReportedSuccessMessage, afterMessageCompletion: nil)
            return
        }
        delegate?.vmShowLoading(R.Strings.productReportingLoadingMessage)

        listingRepository.saveReport(productId) { [weak self] result in
            guard let strongSelf = self else { return }

            var message: String? = nil
            if let _ = result.value {
                strongSelf.isReportedRelay.accept(true)
                message = R.Strings.productReportedSuccessMessage
                self?.trackHelper.trackReportCompleted()
            } else if let error = result.error {
                self?.trackHelper.trackReportError(error.reportError)
                message = R.Strings.productReportedErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    func delete() {
        guard let productId = listingRelay.value.objectId else { return }
        delegate?.vmShowLoading(R.Strings.commonLoading)
        trackHelper.trackDeleteStarted()

        listingRepository.delete(listingId: productId) { [weak self] result in
            var message: String? = nil
            var afterMessageAction: (() -> ())? = nil
            if let _ = result.value, let listing = self?.listingRelay.value {
                afterMessageAction = { [weak self] in
                    self?.navigator?.closeListingAfterDelete(listing)
                }
                self?.trackHelper.trackDeleteCompleted()
            } else if let _ = result.error {
                message = R.Strings.productDeleteSendErrorGeneric
            }

            self?.delegate?.vmHideLoading(message, afterMessageCompletion: afterMessageAction)
        }
    }

    func markUnsold() {
        delegate?.vmShowLoading(nil)
        listingRepository.markAsUnsold(listing: listingRelay.value) { [weak self] result in
            guard let strongSelf = self else { return }
            let message: String
            if let value = result.value {
                strongSelf.listingRelay.accept(value)
                message = strongSelf.listingRelay.value.price.isFree ? R.Strings.productSellAgainFreeSuccessMessage : R.Strings.productSellAgainSuccessMessage
                self?.trackHelper.trackMarkUnsoldCompleted()
            } else {
                message = R.Strings.productSellAgainErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    func sendMessage(type: ChatWrapperMessageType, sectionedFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?) {
        // Optimistic behavior
        let message = LocalMessage(type: type, userId: myUserRepository.myUser?.objectId)
        let messageView = chatViewMessageAdapter.adapt(message, userAvatarData: nil)
        directChatMessages.insert(messageView, atIndex: 0)

        chatWrapper.sendMessageFor(listing: listingRelay.value, type: type) { [weak self] result in
            guard let strongSelf = self else { return }
            if let firstMessage = result.value {
                let messageViewSent = messageView.markAsSent()
                strongSelf.directChatMessages.replace(0, with: messageViewSent)
                let feedPosition = strongSelf.delegate?.trackingFeedPosition ?? .none
                let isFirstMessage = firstMessage && !strongSelf.alreadyTrackedFirstMessageSent
                let visitSource = strongSelf.visitSource(from: strongSelf.visitSource, isFirstMessage: isFirstMessage)
                let badge = strongSelf.sellerRelay.value?.reputationBadge ?? .noBadge
                let badgeParameter = EventParameterUserBadge(userBadge: badge)
                let containsVideo = EventParameterBoolean(bool: strongSelf.listingRelay.value.containsVideo())
                strongSelf.trackHelper.trackMessageSent(isFirstMessage: isFirstMessage,
                                                        messageType: type,
                                                        isShowingFeaturedStripe: strongSelf.isShowingFeaturedStripeRelay.value,
                                                        listingVisitSource: visitSource,
                                                        feedPosition: feedPosition,
                                                        sellerBadge: badgeParameter,
                                                        containsVideo: containsVideo,
                                                        sectionName: sectionedFeedChatTrackingInfo?.sectionId)
                strongSelf.alreadyTrackedFirstMessageSent = true
                if let listingId = strongSelf.listingRelay.value.objectId {
                    strongSelf.keyValueStorage.interestingListingIDs.update(with: listingId)
                    strongSelf.isInterestedRelay.accept(true)
                }
            } else if let error = result.error {
                strongSelf.trackHelper.trackMessageSentError(messageType: type, isShowingFeaturedStripe: strongSelf.isShowingFeaturedStripeRelay.value, error: error)
                switch error {
                case .forbidden:
                    strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.productChatDirectErrorBlockedUserMessage, completion: nil)
                case .network, .internalError, .notFound, .unauthorized, .tooManyRequests, .userNotVerified, .serverError, .searchAlertError:
                    strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.chatSendErrorGeneric, completion: nil)
                case let .wsChatError(chatRepositoryError):
                    switch chatRepositoryError {
                    case .userBlocked:
                        strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.productChatDirectErrorBlockedUserMessage, completion: nil)
                    case .internalError, .notAuthenticated, .userNotVerified, .network, .apiError:
                        strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.chatSendErrorGeneric, completion: nil)
                    case .differentCountry:
                        strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.chatSendErrorDifferentCountry, completion: nil)
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

extension ListingCardViewModel {
    fileprivate func ifLoggedInRunActionElseOpenSignUp(from: EventParameterLoginSourceValue,
                                                       infoMessage: String,
                                                       action: @escaping () -> ()) {
        navigator?.openLoginIfNeededFromProductDetail(from: from, infoMessage: infoMessage, loggedInAction: action)
    }
}


// MARK: - SocialSharerDelegate

extension ListingCardViewModel: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
        let buttonPosition: EventParameterButtonPosition = .none
        trackShareStarted(shareType, buttonPosition: buttonPosition)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        let buttonPosition: EventParameterButtonPosition = .none
        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShowAutoFadingMessage(message, completion: nil)
        }

        trackShareCompleted(shareType, buttonPosition: buttonPosition, state: state)
    }

    private func messageForShareIn(_ shareType: ShareType, finishedWithState state: SocialShareState) -> String? {
        switch (shareType, state) {
        case (.email, .failed):
            return R.Strings.productShareEmailError
        case (.facebook, .failed):
            return R.Strings.sellSendErrorSharingFacebook
        case (.fbMessenger, .failed):
            return R.Strings.sellSendErrorSharingFacebook
        case (.copyLink, .completed):
            return R.Strings.productShareCopylinkOk
        case (.sms, .completed):
            return R.Strings.productShareSmsOk
        case (.sms, .failed):
            return R.Strings.productShareSmsError
        case (_, .completed):
            return R.Strings.productShareGenericOk
        default:
            break
        }
        return nil
    }
}


// MARK: PurchasesShopperDelegate

extension ListingCardViewModel: BumpInfoRequesterDelegate {
    func shopperFinishedProductsRequestForListingId(_ listingId: String?,
                                                    withPurchases purchases: [BumpUpProductData],
                                                    maxCountdown: TimeInterval,
                                                    typePage: EventParameterTypePage?) {
        availablePurchases = purchases
        guard purchases.count == expectedNumberOfAvailablePurchases else {
            bumpUpBannerInfoRelay.accept(nil)
            return
        }
        guard let requestProdId = listingId, let currentProdId = listingRelay.value.objectId,
            requestProdId == currentProdId else { return }

        createBumpeableBanner(forListingId: requestProdId,
                              purchases: purchases,
                              bumpUpType: bumpUpType,
                              typePage: typePage ?? .listingDetail)

    }

    var bumpUpType: BumpUpType {
        if userIsSoftBlocked {
            return .hidden
        } else if hasBumpInProgress {
            return .boost(boostBannerVisible: listingCanBeBoosted)
        } else {
            return .priced
        }
    }

    var expectedNumberOfAvailablePurchases: Int {
        if featureFlags.multiDayBumpUp.isActive && bumpUpType == .priced { return 3 }
        return 1
    }
}

extension ListingCardViewModel: PurchasesShopperDelegate {

    private func isPromotedBump(typePage: EventParameterTypePage?) -> Bool {
        guard let typePage = typePage else { return false }
        return typePage == .edit || typePage == .sellEdit || typePage == .notificationCenter || typePage == .sell
    }

    // Paid Bump Up

    func pricedBumpDidStartWith(storeProduct: PurchaseableProduct, typePage: EventParameterTypePage?,
                                featurePurchaseType: FeaturePurchaseType) {
        let type: BumpUpType = featurePurchaseType.isBoost ? .boost(boostBannerVisible: true) : .priced
        purchaseInProgress = storeProduct
        featurePurchaseTypeInProgress = featurePurchaseType
        storeProductId = storeProduct.productIdentifier
        trackBumpUpStarted(.pay(price: storeProduct.formattedCurrencyPrice),
                           type: type,
                           storeProductId: storeProductId,
                           isPromotedBump: isPromotedBump(typePage: typePage),
                           typePage: typePage,
                           featurePurchaseType: EventParameterPurchaseType(type: featurePurchaseType))
        delegate?.vmShowLoading(R.Strings.bumpUpProcessingPricedText)
    }

    func paymentDidSucceed(paymentId: String, transactionStatus: EventParameterTransactionStatus) {
        trackMobilePaymentComplete(withPaymentId: paymentId, transactionStatus: transactionStatus,
                                   featurePurchaseType: EventParameterPurchaseType(type: featurePurchaseTypeInProgress))
    }

    func pricedBumpPaymentDidFail(withReason reason: String?,
                                  transactionStatus: EventParameterTransactionStatus) {
        trackMobilePaymentFail(withReason: reason, transactionStatus: transactionStatus,
                               featurePurchaseType: EventParameterPurchaseType(type: featurePurchaseTypeInProgress))
        delegate?.vmHideLoading(R.Strings.bumpUpErrorPaymentFailed, afterMessageCompletion: nil)
    }

    func pricedBumpDidSucceed(type: BumpUpType,
                              restoreRetriesCount: Int,
                              transactionStatus: EventParameterTransactionStatus,
                              typePage: EventParameterTypePage?,
                              isBoost: Bool,
                              paymentId: String) {
        trackBumpUpCompleted(.pay(price: purchaseInProgress?.formattedCurrencyPrice ?? ""),
                             type: type,
                             restoreRetriesCount: restoreRetriesCount,
                             network: .notAvailable,
                             transactionStatus: transactionStatus,
                             storeProductId: storeProductId,
                             isPromotedBump: isPromotedBump(typePage: typePage),
                             typePage: typePage,
                             paymentId: paymentId,
                             featurePurchaseType: EventParameterPurchaseType(type: featurePurchaseTypeInProgress))

        delegate?.vmHideLoading(isBoost ? nil : R.Strings.bumpUpPaySuccess, afterMessageCompletion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.vmResetBumpUpBannerCountdown()
            strongSelf.isShowingFeaturedStripeRelay.accept(true)
            if isBoost {
                strongSelf.bumpUpBoostSucceeded()
            }
            if let currentBumpUpInfo = self?.bumpUpBannerInfoRelay.value {
                strongSelf.refreshBumpeableBanner()
            }
        })
    }

    func pricedBumpDidFail(type: BumpUpType, transactionStatus: EventParameterTransactionStatus,
                           typePage: EventParameterTypePage?, isBoost: Bool) {
        trackBumpUpFail(type: type, transactionStatus: transactionStatus, storeProductId: storeProductId,
                        typePage: typePage,
                        featurePurchaseType: EventParameterPurchaseType(type: featurePurchaseTypeInProgress))
        delegate?.vmHideLoading(R.Strings.bumpUpErrorBumpGeneric, afterMessageCompletion: { [weak self] in
            self?.refreshBumpeableBanner()
        })
    }


    // Restore Bump

    func restoreBumpDidStart() {
        trackBumpUpStarted(.pay(price: purchaseInProgress?.formattedCurrencyPrice ?? ""),
                           type: .restore,
                           storeProductId: storeProductId,
                           isPromotedBump: false,
                           typePage: .listingDetail,
                           featurePurchaseType: EventParameterPurchaseType(type: featurePurchaseTypeInProgress))
        delegate?.vmShowLoading(R.Strings.bumpUpProcessingFreeText)
    }
}

extension ListingCardViewModel: ReactiveCompatible {}
extension Reactive where Base: ListingCardViewModel {
    var isMine: Driver<Bool> { return base.isMineRelay.asDriver() }
    var media: Driver<[Media]> { return base.listingRelay.asDriver().map { $0.media } }
    var listing: Driver<Listing> { return base.listingRelay.asDriver() }
    var actionButton: Driver<UIAction?> { return base.actionButtonRelay.asDriver() }
    var seller: Observable<User?> { return base.sellerRelay.asObservable() }
    var isFavorite: Driver<Bool> { return base.isFavoriteRelay.asDriver() }
    var listingStats: Driver<ListingStats?> { return base.listingStatsRelay.asDriver() }
    var showExactLocationOnMap: Driver<Bool> { return base.showExactLocationOnMapRelay.asDriver() }
    var productInfo: Driver<ListingVMProductInfo?> { return base.productInfoRelay.asDriver() }
    var bumpUpBannerInfo: Driver<BumpUpInfo?> { return base.bumpUpBannerInfoRelay.asDriver() }
    var userInfo: Driver<ListingVMUserInfo> { return base.userInfoRelay.asDriver() }
    var status: Driver<ListingViewModelStatus> { return base.statusRelay.asDriver() }
    var isReported: Driver<Bool> { return base.isReportedRelay.asDriver() }
    var isInterested: Driver<Bool> { return base.isInterestedRelay.asDriver() }
    var isShowingFeaturedStripe: Driver<Bool> { return base.isShowingFeaturedStripeRelay.asDriver() }
    var directChatEnabled: Driver<Bool> { return base.directChatEnabledRelay.asDriver() }
    var socialMessage: Driver<SocialMessage?> { return base.socialMessage.asDriver() }
}

extension ListingCardViewModel {
        func trackVisit(_ visitUserAction: ListingVisitUserAction,
                        source: EventParameterListingVisitSource,
                        feedPosition: EventParameterFeedPosition,
                        sectionPosition: EventParameterSectionPosition,
                        feedSectionName: EventParameterSectionName?) {
            let isBumpedUp = isShowingFeaturedStripeRelay.value ? EventParameterBoolean.trueParameter :
                EventParameterBoolean.falseParameter
            let badge = sellerRelay.value?.reputationBadge ?? .noBadge
            let sellerBadge = EventParameterUserBadge(userBadge: badge)
            let isMine = EventParameterBoolean(bool: self.isMine)
            let containsVideo = EventParameterBoolean(bool: listingRelay.value.containsVideo())
            trackHelper.trackVisit(visitUserAction,
                                   source: source,
                                   feedPosition: feedPosition,
                                   sectionPosition: sectionPosition,
                                   isShowingFeaturedStripe: isBumpedUp,
                                   sellerBadge: sellerBadge,
                                   isMine: isMine,
                                   containsVideo: containsVideo,
                                   feedSectionName: feedSectionName)
        }

        func trackVisitMoreInfo(isMine: EventParameterBoolean,
                                adShown: EventParameterBoolean,
                                adType: EventParameterAdType?,
                                queryType: EventParameterAdQueryType?,
                                query: String?,
                                visibility: EventParameterAdVisibility?,
                                errorReason: EventParameterAdSenseRequestErrorReason?) {
            trackHelper.trackVisitMoreInfo(isMine: isMine,
                                           adShown: adShown,
                                           adType: adType,
                                           queryType: queryType,
                                           query: query,
                                           visibility: visibility,
                                           errorReason: errorReason)
        }

        func trackAdTapped(adType: EventParameterAdType?,
                           isMine: EventParameterBoolean,
                           queryType: EventParameterAdQueryType?,
                           query: String?,
                           willLeaveApp: EventParameterBoolean,
                           typePage: EventParameterTypePage) {
            trackHelper.trackAdTapped(adType: adType,
                                      isMine: isMine,
                                      queryType: queryType,
                                      query: query,
                                      willLeaveApp: willLeaveApp,
                                      typePage: typePage)
        }

        func trackInterstitialAdTapped(adType: EventParameterAdType?,
                                       isMine: EventParameterBoolean,
                                       feedPosition: EventParameterFeedPosition,
                                       willLeaveApp: EventParameterBoolean,
                                       typePage: EventParameterTypePage) {
            trackHelper.trackInterstitialAdTapped(adType: adType,
                                                  isMine: isMine,
                                                  feedPosition: feedPosition,
                                                  willLeaveApp: willLeaveApp,
                                                  typePage: typePage)
        }

        func trackInterstitialAdShown(adType: EventParameterAdType?,
                                      isMine: EventParameterBoolean,
                                      feedPosition: EventParameterFeedPosition,
                                      adShown: EventParameterBoolean,
                                      typePage: EventParameterTypePage) {
            trackHelper.trackInterstitialAdShown(adType: adType,
                                                 isMine: isMine,
                                                 feedPosition: feedPosition,
                                                 adShown: adShown,
                                                 typePage: typePage)
        }

        func trackCallTapped(source: EventParameterListingVisitSource,
                             feedPosition: EventParameterFeedPosition) {
            let isBumpedUp = isShowingFeaturedStripeRelay.value ? EventParameterBoolean.trueParameter :
                EventParameterBoolean.falseParameter
            trackHelper.trackCallTapped(source: source,
                                        sellerAverageUserRating: sellerAverageUserRating,
                                        feedPosition: feedPosition,
                                        isShowingFeaturedStripe: isBumpedUp)
        }


        // MARK: Share

        func trackShareStarted(_ shareType: ShareType?, buttonPosition: EventParameterButtonPosition) {
            let isBumpedUp = isShowingFeaturedStripeRelay.value ? EventParameterBoolean.trueParameter :
                EventParameterBoolean.falseParameter
            trackHelper.trackShareStarted(shareType, buttonPosition: buttonPosition, isBumpedUp: isBumpedUp)
        }

        func trackShareCompleted(_ shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
            trackHelper.trackShareCompleted(shareType, buttonPosition: buttonPosition, state: state)
        }

        // MARK: Bump Up

        func trackBumpUpBannerShown(type: BumpUpType, storeProductId: String?) {
            trackHelper.trackBumpUpBannerShown(type: type, storeProductId: storeProductId)
        }

        func trackBumpUpStarted(_ price: EventParameterBumpUpPrice,
                                type: BumpUpType,
                                storeProductId: String?,
                                isPromotedBump: Bool,
                                typePage: EventParameterTypePage?,
                                featurePurchaseType: EventParameterPurchaseType) {
            trackHelper.trackBumpUpStarted(price, type: type, storeProductId: storeProductId, isPromotedBump: isPromotedBump,
                                           typePage: typePage,
                                           featurePurchaseType: featurePurchaseType)
        }

        func trackBumpUpCompleted(_ price: EventParameterBumpUpPrice,
                                  type: BumpUpType,
                                  restoreRetriesCount: Int,
                                  network: EventParameterShareNetwork,
                                  transactionStatus: EventParameterTransactionStatus?,
                                  storeProductId: String?,
                                  isPromotedBump: Bool,
                                  typePage: EventParameterTypePage?,
                                  paymentId: String?,
                                  featurePurchaseType: EventParameterPurchaseType) {
            trackHelper.trackBumpUpCompleted(price, type: type, restoreRetriesCount: restoreRetriesCount, network: network,
                                             transactionStatus: transactionStatus, storeProductId: storeProductId,
                                             isPromotedBump: isPromotedBump, typePage: typePage, paymentId: paymentId,
                                             featurePurchaseType: featurePurchaseType)
        }

        func trackBumpUpFail(type: BumpUpType,
                             transactionStatus: EventParameterTransactionStatus?,
                             storeProductId: String?,
                             typePage: EventParameterTypePage?,
                             featurePurchaseType: EventParameterPurchaseType) {
            trackHelper.trackBumpUpFail(type: type, transactionStatus: transactionStatus, storeProductId: storeProductId,
                                        typePage: typePage,
                                        featurePurchaseType: featurePurchaseType)
        }

        func trackMobilePaymentComplete(withPaymentId paymentId: String, transactionStatus: EventParameterTransactionStatus,
                                        featurePurchaseType: EventParameterPurchaseType) {
            trackHelper.trackMobilePaymentComplete(withPaymentId: paymentId, transactionStatus: transactionStatus,
                                                   featurePurchaseType: featurePurchaseType)
        }

        func trackMobilePaymentFail(withReason reason: String?, transactionStatus: EventParameterTransactionStatus,
                                    featurePurchaseType: EventParameterPurchaseType) {
            trackHelper.trackMobilePaymentFail(withReason: reason, transactionStatus: transactionStatus,
                                               featurePurchaseType: featurePurchaseType)
        }

        func trackBumpUpNotAllowed(reason: EventParameterBumpUpNotAllowedReason) {
            trackHelper.trackBumpUpNotAllowed(reason: reason)
        }

        func trackBumpUpNotAllowedContactUs(reason: EventParameterBumpUpNotAllowedReason) {
            trackHelper.trackBumpUpNotAllowedContactUs(reason: reason)
        }

        func trackOpenFeaturedInfo() {
            trackHelper.trackOpenFeaturedInfo()
        }

        func trackPlayVideo(source: EventParameterListingVisitSource) {
            trackHelper.trackPlayVideo(source: source)
        }
    }

