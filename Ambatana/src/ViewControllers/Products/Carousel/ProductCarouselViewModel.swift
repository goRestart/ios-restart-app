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
    let firstPage: Int = 0
    var nextPage: Int = 1
    var isLastPage: Bool
    var isLoading: Bool = false

    var currentProductViewModel: ProductViewModel?
    var startIndex: Int = 0
    weak var delegate: ProductCarouselViewModelDelegate?
    weak var navigator: ProductDetailNavigator? {
        didSet {
            currentProductViewModel?.navigator = navigator
        }
    }

    var objectChanges: Observable<CollectionChange<ProductCarouselCellModel>> {
        return objects.changesObservable
    }

    var objectCount: Int {
        return objects.value.count
    }

    var shouldShowOnboarding: Bool {
        return !keyValueStorage[.didShowProductDetailOnboarding]
    }

    var shouldShowMoreInfoTooltip: Bool {
        return !keyValueStorage[.productMoreInfoTooltipDismissed]
    }

    let showKeyboardOnFirstAppearance: Bool

    var quickAnswersAvailable: Bool {
        return currentProductViewModel?.directChatEnabled.value ?? false
    }
    let quickAnswersCollapsed: Variable<Bool>

    // Image prefetching
    fileprivate let previousImagesToPrefetch = 1
    fileprivate let nextImagesToPrefetch = 3
    fileprivate var prefetchingIndexes: [Int] = []

    fileprivate var trackingIndex: Int?
    fileprivate var initialThumbnail: UIImage?

    private var activeDisposeBag = DisposeBag()

    fileprivate let source: EventParameterProductVisitSource
    fileprivate let productListRequester: ProductListRequester
    fileprivate var productsViewModels: [String: ProductViewModel] = [:]
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let imageDownloader: ImageDownloaderType
    fileprivate let objects = CollectionVariable<ProductCarouselCellModel>([])

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
                  trackingIndex: trackingIndex)
        syncFirstProduct()
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
                  trackingIndex: trackingIndex)
    }

    convenience init(productListModels: [ProductCellModel]?,
         initialProduct: Product?,
         thumbnailImage: UIImage?,
         productListRequester: ProductListRequester,
         source: EventParameterProductVisitSource,
         showKeyboardOnFirstAppearIfNeeded: Bool,
         trackingIndex: Int?) {
        self.init(productListModels: productListModels,
                  initialProduct: initialProduct,
                  thumbnailImage: thumbnailImage,
                  productListRequester: productListRequester,
                  source: source,
                  featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  imageDownloader: ImageDownloader.sharedInstance,
                  showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded,
                  trackingIndex: trackingIndex)
    }

    init(productListModels: [ProductCellModel]?,
         initialProduct: Product?,
         thumbnailImage: UIImage?,
         productListRequester: ProductListRequester,
         source: EventParameterProductVisitSource,
         featureFlags: FeatureFlaggeable,
         keyValueStorage: KeyValueStorage,
         imageDownloader: ImageDownloaderType,
         showKeyboardOnFirstAppearIfNeeded: Bool,
         trackingIndex: Int?) {
        if let productListModels = productListModels {
            self.objects.appendContentsOf(productListModels.flatMap(ProductCarouselCellModel.adapter))
        } else {
            self.objects.appendContentsOf([initialProduct].flatMap{$0}.map(ProductCarouselCellModel.init))
        }
        self.initialThumbnail = thumbnailImage
        self.productListRequester = productListRequester
        self.source = source
        self.isLastPage = productListRequester.isLastPage(productListModels?.count ?? 0)
        self.keyValueStorage = keyValueStorage
        self.imageDownloader = imageDownloader
        self.showKeyboardOnFirstAppearance = source == .notifications && showKeyboardOnFirstAppearIfNeeded && featureFlags.passiveBuyersShowKeyboard
        self.quickAnswersCollapsed = Variable<Bool>(keyValueStorage[.productDetailQuickAnswersHidden])
        super.init()
        self.startIndex = indexForProduct(initialProduct) ?? 0
        self.currentProductViewModel = viewModelAtIndex(startIndex)
        self.trackingIndex = trackingIndex
        setCurrentIndex(startIndex)
        setupRxBindings()
    }
    
    
    private func syncFirstProduct() {
        currentProductViewModel?.syncProduct() { [weak self] in
            guard let strongSelf = self else { return }
            guard let product = strongSelf.currentProductViewModel?.product.value else { return }
            let newModel = ProductCarouselCellModel(product: product)
            strongSelf.objects.removeAtIndex(strongSelf.startIndex)
            strongSelf.objects.insert(newModel, atIndex: strongSelf.startIndex)
            strongSelf.delegate?.vmRefreshCurrent()
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
        let feedPosition = movement.feedPosition(for: trackingIndex)
        currentProductViewModel?.trackVisit(movement.visitUserAction, source: source, feedPosition: feedPosition)

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
        keyValueStorage[.productMoreInfoTooltipDismissed] = true
        delegate?.vmRemoveMoreInfoTooltip()
    }

    func openShare(_ shareType: ShareType, fromViewController: UIViewController, barButtonItem: UIBarButtonItem? = nil) {
        currentProductViewModel?.openShare(shareType, fromViewController: fromViewController, barButtonItem: barButtonItem)
    }

    func quickAnswersShowButtonPressed() {
        quickAnswersCollapsed.value = false
    }

    func quickAnswersCloseButtonPressed() {
        quickAnswersCollapsed.value = true
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

    private func setupRxBindings() {
        quickAnswersCollapsed.asObservable().skip(1).bindNext { [weak self] collapsed in
            self?.keyValueStorage[.productDetailQuickAnswersHidden] = collapsed
        }.addDisposableTo(disposeBag)
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
            if let prevProduct = productAtIndex(index), let imageUrl = prevProduct.images.first?.fileURL {
                imagesToPrefetch.append(imageUrl)
            }
        }
        imageDownloader.downloadImagesWithURLs(imagesToPrefetch)
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
