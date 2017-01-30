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
    func vmRefreshCurrent()
    func vmRemoveMoreInfoTooltip()
}

enum CarouselMovement {
    case tap, swipeLeft, swipeRight, initial
}

class ProductCarouselViewModel: BaseViewModel {

    // Paginable
    fileprivate var prefetchingIndexes: [Int] = []
    let firstPage: Int = 0
    var nextPage: Int = 1
    var isLastPage: Bool
    var isLoading: Bool = false

    fileprivate let previousImagesToPrefetch = 1
    fileprivate let nextImagesToPrefetch = 3

    var currentProductViewModel: ProductViewModel?
    var startIndex: Int = 0
    var initialThumbnail: UIImage?
    weak var delegate: ProductCarouselViewModelDelegate?
    weak var navigator: ProductDetailNavigator?

    var shareTypes: [ShareType]
    var socialSharer: SocialSharer
    private let featureFlags: FeatureFlaggeable
    private let showKeyboardOnFirstAppearIfNeeded: Bool

    private var activeDisposeBag = DisposeBag()

    var objectChanges: Observable<CollectionChange<ProductCarouselCellModel>> {
        return objects.changesObservable
    }

    var objectCount: Int {
        return objects.value.count
    }

    var shouldShowOnboarding: Bool {
        return !KeyValueStorage.sharedInstance[.didShowProductDetailOnboarding]
    }

    var shouldShowMoreInfoTooltip: Bool {
        return !KeyValueStorage.sharedInstance[.productMoreInfoTooltipDismissed]
    }

    var onboardingShouldShowChatsStep: Bool {
        guard let status = currentProductViewModel?.status.value else { return false }
        switch status {
        case .otherAvailable, .otherAvailableFree:
            return true
        case .pending, .pendingAndCommercializable, .available, .availableFree, .availableAndCommercializable, .notAvailable,
             .otherSold, .sold, .soldFree, .otherSoldFree:
            return false
        }
    }

    var showKeyboardOnFirstAppearance: Bool {
        return source == .notifications && showKeyboardOnFirstAppearIfNeeded && featureFlags.passiveBuyersShowKeyboard
    }

    fileprivate let source: EventParameterProductVisitSource
    fileprivate let productListRequester: ProductListRequester?
    fileprivate var productsViewModels: [String: ProductViewModel] = [:]
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let productRepository: ProductRepository
    fileprivate let objects = CollectionVariable<ProductCarouselCellModel>([])


    // MARK: - Init

    convenience init(product: LocalProduct, productListRequester: ProductListRequester?,
                     navigator: ProductDetailNavigator?, source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let locationManager = Core.locationManager
        let locale = Locale.current
        let socialSharer = SocialSharer()
        let featureFlags = FeatureFlags.sharedInstance

        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
                  productListModels: nil, initialProduct: product, thumbnailImage: nil,
                  productListRequester: productListRequester, navigator: navigator, source: source,
                  locale: locale, locationManager: locationManager,
                  socialSharer: socialSharer, featureFlags: featureFlags,
                  showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded)
        syncFirstProduct()
    }

    convenience init(product: Product, thumbnailImage: UIImage?, productListRequester: ProductListRequester?,
                     navigator: ProductDetailNavigator?, source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let locationManager = Core.locationManager
        let locale = NSLocale.current
        let socialSharer = SocialSharer()
        let featureFlags = FeatureFlags.sharedInstance

        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
                  productListModels: nil, initialProduct: product, thumbnailImage: thumbnailImage,
                  productListRequester: productListRequester, navigator: navigator, source: source,
                  locale: locale, locationManager: locationManager,
                  socialSharer: socialSharer, featureFlags: featureFlags,
                  showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded)
    }

    convenience init(productListModels: [ProductCellModel], initialProduct: Product?, thumbnailImage: UIImage?,
                     productListRequester: ProductListRequester?, navigator: ProductDetailNavigator?,
                     source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let locationManager = Core.locationManager
        let locale = NSLocale.current
        let socialSharer = SocialSharer()
        let featureFlags = FeatureFlags.sharedInstance

        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
                  productListModels: productListModels, initialProduct: initialProduct,
                  thumbnailImage: thumbnailImage, productListRequester: productListRequester, navigator: navigator,
                  source: source, locale: locale, locationManager: locationManager,
                  socialSharer: socialSharer, featureFlags: featureFlags,
                  showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded)
    }

    init(myUserRepository: MyUserRepository, productRepository: ProductRepository,
         productListModels: [ProductCellModel]?, initialProduct: Product?, thumbnailImage: UIImage?,
         productListRequester: ProductListRequester?, navigator: ProductDetailNavigator?,
         source: EventParameterProductVisitSource, locale: Locale, locationManager: LocationManager,
         socialSharer: SocialSharer, featureFlags: FeatureFlaggeable,
         showKeyboardOnFirstAppearIfNeeded: Bool) {
        let countryCode = locationManager.currentPostalAddress?.countryCode ?? locale.lg_countryCode
        self.myUserRepository = myUserRepository
        self.productRepository = productRepository
        if let productListModels = productListModels {
            self.objects.appendContentsOf(productListModels.flatMap(ProductCarouselCellModel.adapter))
        } else {
            self.objects.appendContentsOf([initialProduct].flatMap{$0}.map(ProductCarouselCellModel.init))
        }
        self.initialThumbnail = thumbnailImage
        self.productListRequester = productListRequester
        self.navigator = navigator
        self.source = source
        self.isLastPage = productListRequester?.isLastPage(productListModels?.count ?? 0) ?? true
        self.shareTypes = ShareType.shareTypesForCountry(countryCode, maxButtons: 4, nativeShare: .normal)
        self.socialSharer = socialSharer
        self.featureFlags = featureFlags
        self.showKeyboardOnFirstAppearIfNeeded = showKeyboardOnFirstAppearIfNeeded
        super.init()
        self.socialSharer.delegate = self
        self.startIndex = indexForProduct(initialProduct) ?? 0
        self.currentProductViewModel = viewModelAtIndex(startIndex)
        setCurrentIndex(startIndex)
    }
    
    
    private func syncFirstProduct() {
        currentProductViewModel?.syncProduct() { [weak self] in
            guard let `self` = self else { return }
            guard let product = self.currentProductViewModel?.product.value else { return }
            let newModel = ProductCarouselCellModel(product: product)
            self.objects.removeAtIndex(self.startIndex)
            self.objects.insert(newModel, atIndex: self.startIndex)
            self.delegate?.vmRefreshCurrent()
        }
    }
    
    
    func indexForProduct(_ product: Product?) -> Int? {
        guard let product = product else { return nil }
        for i in 0..<objects.value.count {
            switch objects.value[i] {
            case .productCell(let data):
                if data.objectId == product.objectId {
                    return i
                }
            }
        }
        return nil
    }


    // MARK: - Public Methods

    func close() {
        navigator?.closeProductDetail()
    }

    func moveToProductAtIndex(_ index: Int, delegate: ProductViewModelDelegate, movement: CarouselMovement) {
        guard let viewModel = viewModelAtIndex(index) else { return }
        currentProductViewModel?.active = false
        currentProductViewModel = viewModel
        currentProductViewModel?.delegate = delegate
        currentProductViewModel?.active = true
        currentProductViewModel?.trackVisit(movement.visitUserAction, source: source)

        activeDisposeBag = DisposeBag()
        currentProductViewModel?.product.asObservable().skip(1).bindNext { [weak self] updatedProduct in
            guard let strongSelf = self else { return }
            guard 0..<strongSelf.objectCount ~= index else { return }
            strongSelf.objects.replace(index..<(index+1), with: [ProductCarouselCellModel(product: updatedProduct)])
            strongSelf.delegate?.vmRefreshCurrent()
        }.addDisposableTo(activeDisposeBag)

        prefetchNeighborsImages(index, movement: movement)
    }

    func productAtIndex(_ index: Int) -> Product? {
        guard 0..<objectCount ~= index else { return nil }
        let item = objects.value[index]
        switch item {
        case .productCell(let product):
            return product
        }
    }
    
    func thumbnailAtIndex(_ index: Int) -> UIImage? {
        if index == startIndex { return initialThumbnail }
        guard 0..<objectCount ~= index else { return nil }
        return viewModelAtIndex(index)?.thumbnailImage
    }
    
    func viewModelAtIndex(_ index: Int) -> ProductViewModel? {
        guard let product = productAtIndex(index) else { return nil }
        return getOrCreateViewModel(product)
    }

    func viewModelForProduct(_ product: Product) -> ProductViewModel {
        return ProductViewModel(product: product, thumbnailImage: nil, navigator: navigator)
    }

    func openProductOwnerProfile() {
        currentProductViewModel?.openProductOwnerProfile()
    }

    func openChatWithSeller() {
        currentProductViewModel?.chatWithSeller()
    }
    
    func didOpenMoreInfo() {
        currentProductViewModel?.trackVisitMoreInfo()
        KeyValueStorage.sharedInstance[.productMoreInfoTooltipDismissed] = true
        delegate?.vmRemoveMoreInfoTooltip()
    }

    func openShare(_ shareType: ShareType, fromViewController: UIViewController, barButtonItem: UIBarButtonItem? = nil) {
        currentProductViewModel?.openShare(shareType, fromViewController: fromViewController, barButtonItem: barButtonItem)
    }

    func openFreeBumpUpView() {
        guard let product = currentProductViewModel?.product.value,
            let socialMessage = currentProductViewModel?.freeBumpUpShareMessage.value,
        let paymentItemId = currentProductViewModel?.paymentItemId else { return }
        currentProductViewModel?.trackBumpUpStarted(.free)
        navigator?.openFreeBumpUpForProduct(product: product, socialMessage: socialMessage, withPaymentItemId: paymentItemId)
    }

    func openPaymentBumpUpView() {
        guard let product = currentProductViewModel?.product.value else { return }
        guard let purchaseableProduct = currentProductViewModel?.bumpUpPurchaseableProduct else { return }
        currentProductViewModel?.trackBumpUpStarted(.pay(price: purchaseableProduct.formattedCurrencyPrice))
        navigator?.openPayBumpUpForProduct(product: product, purchaseableProduct: purchaseableProduct)
    }

    func refreshBannerInfo() {
        currentProductViewModel?.refreshBumpeableBanner()
    }
    // MARK: - Private Methods
    
    private func getOrCreateViewModel(_ product: Product) -> ProductViewModel? {
        guard let productId = product.objectId else { return nil }
        if let vm = productsViewModels[productId] {
            return vm
        }
        let vm = viewModelForProduct(product)
        productsViewModels[productId] = vm
        return vm
    }
}

extension ProductCarouselViewModel: Paginable {
    func retrievePage(_ page: Int) {
        let isFirstPage = (page == firstPage)
        isLoading = true
        
        let completion: ProductsCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            self?.isLoading = false
            if let newProducts = result.value {
                strongSelf.nextPage = strongSelf.nextPage + 1
                strongSelf.objects.appendContentsOf(newProducts.map(ProductCarouselCellModel.init))
                
                strongSelf.isLastPage = strongSelf.productListRequester?.isLastPage(newProducts.count) ?? true
                if newProducts.isEmpty && !strongSelf.isLastPage {
                    strongSelf.retrieveNextPage()
                }
            }
        }
        
        if isFirstPage {
            productListRequester?.retrieveFirstPage(completion)
        } else {
            productListRequester?.retrieveNextPage(completion)
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
            if let prevProduct = productAtIndex(index), let imageUrl = prevProduct.images.first?.fileURL {
                imagesToPrefetch.append(imageUrl)
            }
        }
        ImageDownloader.sharedInstance.downloadImagesWithURLs(imagesToPrefetch)
    }
}


// MARK: - SocialSharerDelegate

extension ProductCarouselViewModel: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShowAutoFadingMessage(message, completion: nil)
        }
        currentProductViewModel?.trackShareCompleted(shareType, buttonPosition: .top, state: state)
    }

    private func messageForShareIn(_ shareType: ShareType, finishedWithState state: SocialShareState) -> String? {
        switch (shareType, state) {
        case (.email, .failed):
            return LGLocalizedString.productShareEmailError
        case (.facebook, .failed):
            return LGLocalizedString.sellSendErrorSharingFacebook
        case (.fbMessenger, .failed):
            return LGLocalizedString.sellSendErrorSharingFacebook
        case (.sms, .completed):
            return LGLocalizedString.productShareSmsOk
        case (.sms, .failed):
            return LGLocalizedString.productShareSmsError
        case (.copyLink, .completed):
            return LGLocalizedString.productShareCopylinkOk
        case (_, .completed):
            return LGLocalizedString.productShareGenericOk
        default:
            break
        }
        return nil
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
}
