//
//  ProductCarouselViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol ProductCarouselViewModelDelegate: BaseViewModelDelegate {
    func vmRemoveMoreInfoTooltip()
    func vmShowOnboarding()

    // Forward from ProductViewModelDelegate
    func vmOpenCommercialDisplay(_ displayVM: CommercialDisplayViewModel)
    func vmAskForRating()
    func vmShowCarouselOptions(_ cancelLabel: String, actions: [UIAction])
    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?)
    func vmResetBumpUpBannerCountdown()
}

enum CarouselMovement {
    case tap, swipeLeft, swipeRight, initial
}

class ProductCarouselViewModel: BaseViewModel {

    // Paginable
    let firstPage: Int = 0
    var nextPage: Int = 1
    var isLastPage: Bool
    var isLoading: Bool = false

    var currentProductViewModel: ProductViewModel?
    let startIndex: Int
    fileprivate(set) var currentIndex: Int = 0 {
        didSet {
            // Just for pagination
            setCurrentIndex(currentIndex)
        }
    }
    weak var delegate: ProductCarouselViewModelDelegate?
    weak var navigator: ProductDetailNavigator? {
        didSet {
            currentProductViewModel?.navigator = navigator
        }
    }

    let objects = CollectionVariable<ProductCarouselCellModel>([])
    var objectChanges: Observable<CollectionChange<ProductCarouselCellModel>> {
        return objects.changesObservable
    }

    var objectCount: Int {
        return objects.value.count
    }

    var shouldShowMoreInfoTooltip: Bool {
        return !keyValueStorage[.productMoreInfoTooltipDismissed]
    }

    let showKeyboardOnFirstAppearance: Bool
    let shouldClearTextWhenBeginEditing: Bool

    let productInfo = Variable<ProductVMProductInfo?>(nil)
    let productImageURLs = Variable<[URL]>([])
    let userInfo = Variable<ProductVMUserInfo?>(nil)
    let ListingStats = Variable<ListingStats?>(nil)

    let navBarButtons = Variable<[UIAction]>([])
    let actionButtons = Variable<[UIAction]>([])

    let status = Variable<ProductViewModelStatus>(.pending)
    let isFeatured = Variable<Bool>(false)

    let quickAnswers = Variable<[QuickAnswer]>([])
    let quickAnswersAvailable = Variable<Bool>(false)
    let quickAnswersCollapsed: Variable<Bool>

    let directChatEnabled = Variable<Bool>(false)
    var directChatPlaceholder = Variable<String>("")
    let directChatMessages = CollectionVariable<ChatViewMessage>([])

    let isFavorite = Variable<Bool>(false)
    let favoriteButtonState = Variable<ButtonState>(.enabled)
    let shareButtonState = Variable<ButtonState>(.hidden)
    let bumpUpBannerInfo = Variable<BumpUpInfo?>(nil)

    let socialMessage = Variable<SocialMessage?>(nil)
    let socialSharer = Variable<SocialSharer>(SocialSharer())

    // UI - Input
    let moreInfoState = Variable<MoreInfoState>(.hidden)

    // Image prefetching
    fileprivate let previousImagesToPrefetch = 1
    fileprivate let nextImagesToPrefetch = 3
    fileprivate var prefetchingIndexes: [Int] = []

    fileprivate var shouldShowOnboarding: Bool {
        return !keyValueStorage[.didShowProductDetailOnboarding]
    }

    fileprivate var trackingIndex: Int?
    fileprivate var initialThumbnail: UIImage?

    private var activeDisposeBag = DisposeBag()

    fileprivate let source: EventParameterProductVisitSource
    fileprivate let productListRequester: ProductListRequester
    fileprivate var productsViewModels: [String: ProductViewModel] = [:]
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let imageDownloader: ImageDownloaderType
    fileprivate let productViewModelMaker: ProductViewModelMaker

    fileprivate let disposeBag = DisposeBag()

    override var active: Bool {
        didSet {
            currentProductViewModel?.active = active
        }
    }

    // MARK: - Init

    convenience init(product: LocalProduct,
                     productListRequester: ProductListRequester,
                     source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool,
                     trackingIndex: Int?) {
        self.init(productListModels: nil,
                  initialProduct: product,
                  thumbnailImage: nil,
                  productListRequester: productListRequester,
                  source: source,
                  showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded,
                  trackingIndex: trackingIndex,
                  firstProductSyncRequired: true)
    }

    convenience init(product: Product,
                     thumbnailImage: UIImage?,
                     productListRequester: ProductListRequester,
                     source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool,
                     trackingIndex: Int?) {
        self.init(productListModels: nil,
                  initialProduct: product,
                  thumbnailImage: thumbnailImage,
                  productListRequester: productListRequester,
                  source: source,
                  showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded,
                  trackingIndex: trackingIndex,
                  firstProductSyncRequired: false)
    }

    convenience init(productListModels: [ProductCellModel]?,
         initialProduct: Product?,
         thumbnailImage: UIImage?,
         productListRequester: ProductListRequester,
         source: EventParameterProductVisitSource,
         showKeyboardOnFirstAppearIfNeeded: Bool,
         trackingIndex: Int?,
         firstProductSyncRequired: Bool) {
        self.init(productListModels: productListModels,
                  initialProduct: initialProduct,
                  thumbnailImage: thumbnailImage,
                  productListRequester: productListRequester,
                  source: source,
                  showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded,
                  trackingIndex: trackingIndex,
                  firstProductSyncRequired: firstProductSyncRequired,
                  featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  imageDownloader: ImageDownloader.sharedInstance,
                  productViewModelMaker: ProductViewModel.ConvenienceMaker())
    }

    init(productListModels: [ProductCellModel]?,
         initialProduct: Product?,
         thumbnailImage: UIImage?,
         productListRequester: ProductListRequester,
         source: EventParameterProductVisitSource,
         showKeyboardOnFirstAppearIfNeeded: Bool,
         trackingIndex: Int?,
         firstProductSyncRequired: Bool,
         featureFlags: FeatureFlaggeable,
         keyValueStorage: KeyValueStorageable,
         imageDownloader: ImageDownloaderType,
         productViewModelMaker: ProductViewModelMaker) {
        if let productListModels = productListModels {
            self.objects.appendContentsOf(productListModels.flatMap(ProductCarouselCellModel.adapter))
            self.isLastPage = productListRequester.isLastPage(productListModels.count)
        } else {
            self.objects.appendContentsOf([initialProduct].flatMap{$0}.map(ProductCarouselCellModel.init))
            self.isLastPage = false
        }
        self.initialThumbnail = thumbnailImage
        self.productListRequester = productListRequester
        self.source = source
        self.showKeyboardOnFirstAppearance = source == .notifications && showKeyboardOnFirstAppearIfNeeded && featureFlags.passiveBuyersShowKeyboard
        self.shouldClearTextWhenBeginEditing = featureFlags.periscopeRemovePredefinedText
        self.quickAnswersCollapsed = Variable<Bool>(keyValueStorage[.productDetailQuickAnswersHidden])
        self.keyValueStorage = keyValueStorage
        self.imageDownloader = imageDownloader
        self.productViewModelMaker = productViewModelMaker
        if let initialProduct = initialProduct {
            self.startIndex = objects.value.index(where: { $0.product.objectId == initialProduct.objectId}) ?? 0
        } else {
            self.startIndex = 0
        }
        self.currentIndex = startIndex
        super.init()
        self.trackingIndex = trackingIndex
        setupRxBindings()
        moveToProductAtIndex(startIndex, movement: .initial)

        if firstProductSyncRequired {
            syncFirstProduct()
        }
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime && shouldShowOnboarding {
            delegate?.vmShowOnboarding()
        }

        // Tracking
        if let trackingIndex = trackingIndex, currentIndex == startIndex {
            currentProductViewModel?.trackVisit(.none, source: source, feedPosition: .position(index: trackingIndex))
        } else {
            currentProductViewModel?.trackVisit(.none, source: source, feedPosition: .none)
        }
    }
    
    
    private func syncFirstProduct() {
        currentProductViewModel?.syncProduct() { [weak self] in
            guard let strongSelf = self else { return }
            guard let product = strongSelf.currentProductViewModel?.product.value else { return }
            let newModel = ProductCarouselCellModel(product: product)
            strongSelf.objects.replace(strongSelf.startIndex, with: newModel)
        }
    }


    // MARK: - Public Methods

    func close() {
        navigator?.closeProductDetail()
    }

    func moveToProductAtIndex(_ index: Int, movement: CarouselMovement) {
        guard let viewModel = viewModelAt(index: index) else { return }
        currentProductViewModel?.active = false
        currentProductViewModel?.delegate = nil
        currentProductViewModel = viewModel
        currentProductViewModel?.delegate = self
        currentProductViewModel?.active = active
        currentIndex = index
        
        setupCurrentProductVMRxBindings(forIndex: index)
        prefetchNeighborsImages(index, movement: movement)

        // Tracking
        if active {
            let feedPosition = movement.feedPosition(for: trackingIndex)
            currentProductViewModel?.trackVisit(movement.visitUserAction, source: source, feedPosition: feedPosition)
        }
    }

    func productCellModelAt(index: Int) -> ProductCarouselCellModel? {
        guard 0..<objectCount ~= index else { return nil }
        return objects.value[index]
    }
    
    func thumbnailAtIndex(_ index: Int) -> UIImage? {
        if index == startIndex { return initialThumbnail }
        return nil
    }

    func userAvatarPressed() {
        currentProductViewModel?.openProductOwnerProfile()
    }

    func directMessagesItemPressed() {
        currentProductViewModel?.chatWithSeller()
    }

    func quickAnswersShowButtonPressed() {
        quickAnswersCollapsed.value = false
    }

    func quickAnswersCloseButtonPressed() {
        quickAnswersCollapsed.value = true
    }

    func send(quickAnswer: QuickAnswer) {
        currentProductViewModel?.sendQuickAnswer(quickAnswer: quickAnswer)
    }

    func send(directMessage: String, isDefaultText: Bool) {
        currentProductViewModel?.sendDirectMessage(directMessage, isDefaultText: isDefaultText)
    }

    func editButtonPressed() {
        currentProductViewModel?.editProduct()
    }

    func favoriteButtonPressed() {
        currentProductViewModel?.switchFavorite()
    }

    func shareButtonPressed() {
        currentProductViewModel?.shareProduct()
    }
    
    // MARK: - Private Methods

    fileprivate func productAt(index: Int) -> Product? {
        return productCellModelAt(index: index)?.product
    }

    private func viewModelAt(index: Int) -> ProductViewModel? {
        guard let product = productAt(index: index) else { return nil }
        return viewModelFor(product: product)
    }
    
    private func viewModelFor(product: Product) -> ProductViewModel? {
        guard let productId = product.objectId else { return nil }
        if let vm = productsViewModels[productId] {
            return vm
        }
        let vm = productViewModelMaker.make(product: product)
        vm.navigator = navigator
        productsViewModels[productId] = vm
        return vm
    }

    private func setupRxBindings() {
        quickAnswersCollapsed.asObservable().skip(1).bindNext { [weak self] collapsed in
            self?.keyValueStorage[.productDetailQuickAnswersHidden] = collapsed
        }.addDisposableTo(disposeBag)

        moreInfoState.asObservable().map { $0 == .shown }.distinctUntilChanged().filter { $0 }.bindNext { [weak self] _ in
            self?.currentProductViewModel?.trackVisitMoreInfo()
            self?.keyValueStorage[.productMoreInfoTooltipDismissed] = true
            self?.delegate?.vmRemoveMoreInfoTooltip()
        }.addDisposableTo(disposeBag)
    }

    private func setupCurrentProductVMRxBindings(forIndex index: Int) {
        activeDisposeBag = DisposeBag()
        guard let currentVM = currentProductViewModel else { return }
        currentVM.product.asObservable().skip(1).bindNext { [weak self] updatedProduct in
            guard let strongSelf = self else { return }
            strongSelf.objects.replace(index, with: ProductCarouselCellModel(product:updatedProduct))
        }.addDisposableTo(activeDisposeBag)

        currentVM.status.asObservable().bindTo(status).addDisposableTo(activeDisposeBag)
        currentVM.isShowingFeaturedStripe.asObservable().bindTo(isFeatured).addDisposableTo(activeDisposeBag)

        currentVM.productInfo.asObservable().bindTo(productInfo).addDisposableTo(activeDisposeBag)
        currentVM.productImageURLs.asObservable().bindTo(productImageURLs).addDisposableTo(activeDisposeBag)
        currentVM.userInfo.asObservable().bindTo(userInfo).addDisposableTo(activeDisposeBag)
        currentVM.ListingStats.asObservable().bindTo(ListingStats).addDisposableTo(activeDisposeBag)

        currentVM.actionButtons.asObservable().bindTo(actionButtons).addDisposableTo(activeDisposeBag)
        currentVM.navBarButtons.asObservable().bindTo(navBarButtons).addDisposableTo(activeDisposeBag)

        quickAnswers.value = currentVM.quickAnswers
        currentVM.directChatEnabled.asObservable().bindTo(quickAnswersAvailable).addDisposableTo(activeDisposeBag)

        currentVM.directChatEnabled.asObservable().bindTo(directChatEnabled).addDisposableTo(activeDisposeBag)
        currentVM.directChatMessages.bindTo(directChatMessages).addDisposableTo(activeDisposeBag)
        directChatPlaceholder.value = currentVM.directChatPlaceholder

        currentVM.isFavorite.asObservable().bindTo(isFavorite).addDisposableTo(activeDisposeBag)
        currentVM.favoriteButtonState.asObservable().bindTo(favoriteButtonState).addDisposableTo(activeDisposeBag)
        currentVM.shareButtonState.asObservable().bindTo(shareButtonState).addDisposableTo(activeDisposeBag)
        currentVM.bumpUpBannerInfo.asObservable().bindTo(bumpUpBannerInfo).addDisposableTo(activeDisposeBag)

        currentVM.socialMessage.asObservable().bindTo(socialMessage).addDisposableTo(activeDisposeBag)
        socialSharer.value = currentVM.socialSharer

        moreInfoState.asObservable().bindTo(currentVM.moreInfoState).addDisposableTo(activeDisposeBag)
    }
}

extension ProductCarouselViewModel: Paginable {
    func retrievePage(_ page: Int) {
        let isFirstPage = (page == firstPage)
        isLoading = true
        
        let completion: ListingsCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            self?.isLoading = false
            if let newProducts = result.value {
                strongSelf.nextPage = strongSelf.nextPage + 1
                strongSelf.objects.appendContentsOf(newProducts.map(ProductCarouselCellModel.init))
                
                strongSelf.isLastPage = strongSelf.productListRequester.isLastPage(newProducts.count)
                if newProducts.isEmpty && !strongSelf.isLastPage {
                    strongSelf.retrieveNextPage()
                }
            }
        }
        
        if isFirstPage {
            productListRequester.retrieveFirstPage(completion)
        } else {
            productListRequester.retrieveNextPage(completion)
        }
    }
}


// MARK: > Image PreCaching

extension ProductCarouselViewModel {
    func prefetchNeighborsImages(_ index: Int, movement: CarouselMovement) {
        let range: CountableClosedRange<Int>
        switch movement {
        case .initial:
            range = (index-previousImagesToPrefetch)...(index+nextImagesToPrefetch)
        case .tap, .swipeRight:
            range = (index+1)...(index+nextImagesToPrefetch)
        case .swipeLeft:
            range = (index-previousImagesToPrefetch)...(index-1)
        }
        var imagesToPrefetch: [URL] = []
        for index in range {
            guard !prefetchingIndexes.contains(index) else { continue }
            prefetchingIndexes.append(index)
            if let imageUrl = productAt(index: index)?.images.first?.fileURL {
                imagesToPrefetch.append(imageUrl)
            }
        }
        imageDownloader.downloadImagesWithURLs(imagesToPrefetch)
    }
}


// MARK: - ProductViewModelDelegate

extension ProductCarouselViewModel: ProductViewModelDelegate {
    // ProductViewModelDelegate forwarding methods
    func vmOpenCommercialDisplay(_ displayVM: CommercialDisplayViewModel) {
        delegate?.vmOpenCommercialDisplay(displayVM)
    }
    func vmAskForRating() {
        delegate?.vmAskForRating()
    }
    func vmShowProductDetailOptions(_ cancelLabel: String, actions: [UIAction]) {
        var finalActions: [UIAction] = actions

        //Adding show onboarding action
        let title = LGLocalizedString.productOnboardingShowAgainButtonTitle
        finalActions.append(UIAction(interface: .text(title), action: { [weak self] in
            self?.delegate?.vmShowOnboarding()
        }))

        if quickAnswersAvailable.value {
            //Adding show/hide quick answers option
            if quickAnswersCollapsed.value {
                finalActions.append(UIAction(interface: .text(LGLocalizedString.directAnswersShow), action: {
                    [weak self] in self?.quickAnswersShowButtonPressed()
                }))
            } else {
                finalActions.append(UIAction(interface: .text(LGLocalizedString.directAnswersHide), action: {
                    [weak self] in self?.quickAnswersCloseButtonPressed()
                }))
            }
        }
        delegate?.vmShowCarouselOptions(cancelLabel, actions: finalActions)
    }

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        guard let delegate = delegate else { return (UIViewController(), nil) }
        return delegate.vmShareViewControllerAndItem()
    }

    func vmResetBumpUpBannerCountdown() {
        delegate?.vmResetBumpUpBannerCountdown()
    }

    // BaseViewModelDelegate forwarding methods
    
    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(message, completion: completion)
    }
    func vmShowLoading(_ loadingMessage: String?) {
        delegate?.vmShowLoading(loadingMessage)
    }
    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        delegate?.vmHideLoading(finishedMessage, afterMessageCompletion: afterMessageCompletion)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, actions: actions)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, actions: actions, dismissAction: dismissAction)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions, dismissAction: dismissAction)
    }
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, actions: actions)
    }
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, cancelLabel: cancelLabel, actions: actions)
    }
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelLabel, actions: actions)
    }
    func vmOpenInternalURL(_ url: URL) {
        delegate?.vmOpenInternalURL(url)
    }
    func vmPop() {
        delegate?.vmPop()
    }
    func vmDismiss(_ completion: (() -> Void)?) {
        delegate?.vmDismiss(completion)
    }
}



// MARK: - Tracking

extension CarouselMovement {
    var visitUserAction: ProductVisitUserAction {
        switch self {
        case .tap:
            return .tap
        case .swipeLeft:
            return .swipeLeft
        case .swipeRight:
            return .swipeRight
        case .initial:
            return .none
        }
    }
    func feedPosition(for index: Int?) -> EventParameterFeedPosition {
        guard let index = index else  { return .none }
        switch self {
        case .tap, .swipeLeft, .swipeRight:
            return .none
        case .initial:
            return .position(index: index)
        }
    }
}
