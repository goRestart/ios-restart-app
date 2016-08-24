//
//  ProductCarouselViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import CollectionVariable

protocol ProductCarouselViewModelDelegate: BaseViewModelDelegate {
    func vmRefreshCurrent()
    func vmRemoveMoreInfoTooltip()
}

enum CarouselMovement {
    case Tap, SwipeLeft, SwipeRight, Initial
}

class ProductCarouselViewModel: BaseViewModel {

    // Paginable
    var nextPage: Int = 0
    var isLastPage: Bool = false
    var isLoading: Bool = false

    private let previousImagesToPrefetch = 1
    private let nextImagesToPrefetch = 3

    var currentProductViewModel: ProductViewModel?
    var startIndex: Int = 0
    var initialThumbnail: UIImage?
    weak var delegate: ProductCarouselViewModelDelegate?
    weak var tabNavigator: TabNavigator?

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
        case .OtherAvailable:
            return true
        case .Pending, .PendingAndCommercializable, .Available, .AvailableAndCommercializable, .NotAvailable,
             .OtherSold, .Sold:
            return false
        }
    }

    private let source: EventParameterProductVisitSource
    private var productListRequester: ProductListRequester?
    private var productsViewModels: [String: ProductViewModel] = [:]
    private let myUserRepository: MyUserRepository
    private let productRepository: ProductRepository
    private let objects = CollectionVariable<ProductCarouselCellModel>([])


    // MARK: - Init
    
    convenience init(chatProduct: ChatProduct, chatInterlocutor: ChatInterlocutor, thumbnailImage: UIImage?,
                     productListRequester: ProductListRequester?, tabNavigator: TabNavigator?,
                     source: EventParameterProductVisitSource) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let product = productRepository.build(fromChatproduct: chatProduct, chatInterlocutor: chatInterlocutor)
        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
                  productListModels: nil, initialProduct: product, thumbnailImage: thumbnailImage,
                  productListRequester: productListRequester, tabNavigator: tabNavigator, source: source)
        syncFirstProduct()
    }

    convenience init(product: Product, thumbnailImage: UIImage?, productListRequester: ProductListRequester?,
                     tabNavigator: TabNavigator?, source: EventParameterProductVisitSource) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
                  productListModels: nil, initialProduct: product, thumbnailImage: thumbnailImage,
                  productListRequester: productListRequester, tabNavigator: tabNavigator, source: source)
    }

    convenience init(productListModels: [ProductCellModel], initialProduct: Product?, thumbnailImage: UIImage?,
                     productListRequester: ProductListRequester?, tabNavigator: TabNavigator?,
                     source: EventParameterProductVisitSource) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
                  productListModels: productListModels, initialProduct: initialProduct,
                  thumbnailImage: thumbnailImage, productListRequester: productListRequester, tabNavigator: tabNavigator,
                  source: source)
    }

    init(myUserRepository: MyUserRepository, productRepository: ProductRepository,
         productListModels: [ProductCellModel]?, initialProduct: Product?, thumbnailImage: UIImage?,
         productListRequester: ProductListRequester?, tabNavigator: TabNavigator?,
         source: EventParameterProductVisitSource) {
        self.myUserRepository = myUserRepository
        self.productRepository = productRepository
        if let productListModels = productListModels {
            self.objects.appendContentsOf(productListModels.flatMap(ProductCarouselCellModel.adapter))
        } else {
            self.objects.appendContentsOf([initialProduct].flatMap{$0}.map(ProductCarouselCellModel.init))
        }
        self.initialThumbnail = thumbnailImage
        self.productListRequester = productListRequester
        self.tabNavigator = tabNavigator
        self.source = source
        super.init()
        self.startIndex = indexForProduct(initialProduct) ?? 0
        self.currentProductViewModel = viewModelAtIndex(startIndex)
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
    
    
    func indexForProduct(product: Product?) -> Int? {
        guard let product = product else { return nil }
        for i in 0..<objects.value.count {
            switch objects.value[i] {
            case .ProductCell(let data):
                if data.objectId == product.objectId {
                    return i
                }
            }
        }
        return nil
    }


    // MARK: - Public Methods

    func moveToProductAtIndex(index: Int, delegate: ProductViewModelDelegate, movement: CarouselMovement) {
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

        prefetchImages(index)
        prefetchNeighborsImages(index, movement: movement)
    }

    func productAtIndex(index: Int) -> Product? {
        guard 0..<objectCount ~= index else { return nil }
        let item = objects.value[index]
        switch item {
        case .ProductCell(let product):
            return product
        }
    }
    
    func thumbnailAtIndex(index: Int) -> UIImage? {
        if index == startIndex { return initialThumbnail }
        guard 0..<objectCount ~= index else { return nil }
        return viewModelAtIndex(index)?.thumbnailImage
    }
    
    func viewModelAtIndex(index: Int) -> ProductViewModel? {
        guard let product = productAtIndex(index) else { return nil }
        return getOrCreateViewModel(product)
    }

    func viewModelForProduct(product: Product) -> ProductViewModel {
        return ProductViewModel(product: product, thumbnailImage: nil, tabNavigator: tabNavigator)
    }

    func openProductOwnerProfile() {
        currentProductViewModel?.openProductOwnerProfile()
    }

    func didOpenMoreInfo() {
        currentProductViewModel?.trackVisitMoreInfo()
        KeyValueStorage.sharedInstance[.productMoreInfoTooltipDismissed] = true
        delegate?.vmRemoveMoreInfoTooltip()
    }

    
    // MARK: - Private Methods
    
    func getOrCreateViewModel(product: Product) -> ProductViewModel? {
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
    func retrievePage(page: Int) {
        let isFirstPage = (page == firstPage)
        isLoading = true
        
        let completion: ProductsCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            if let newProducts = result.value {
                if isFirstPage {
                    strongSelf.objects.removeAll()
                }
                strongSelf.objects.appendContentsOf(newProducts.map(ProductCarouselCellModel.init))
                strongSelf.isLastPage = strongSelf.productListRequester?.isLastPage(newProducts.count) ?? true
                self?.isLastPage = newProducts.count == 0
            }
            self?.isLoading = false
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
    func prefetchNeighborsImages(index: Int, movement: CarouselMovement) {
        let range: Range<Int>
        switch movement {
        case .Initial:
            range = (index-previousImagesToPrefetch)...(index+nextImagesToPrefetch)
        case .Tap, .SwipeRight:
            range = (index+1)...(index+nextImagesToPrefetch)
        case .SwipeLeft:
            range = (index-previousImagesToPrefetch)...(index-1)
        }
        
        var imagesToPrefetch: [NSURL] = []
        for index in range {
            if let prevProduct = productAtIndex(index), let imageUrl = prevProduct.images.first?.fileURL {
                imagesToPrefetch.append(imageUrl)
            }
        }
        ImageDownloader.sharedInstance.downloadImagesWithURLs(imagesToPrefetch)
    }

    func prefetchImages(index: Int) {
        guard let product = productAtIndex(index) else { return }
        let urls = product.images.flatMap({$0.fileURL})
        ImageDownloader.sharedInstance.downloadImagesWithURLs(urls)
    }
}


// MARK: > Native Share Delegate

extension ProductCarouselViewModel: NativeShareDelegate {

    func nativeShareInFacebook() {
        currentProductViewModel?.shareInFacebook(.Top)
        currentProductViewModel?.shareInFBCompleted()
    }

    func nativeShareInTwitter() {
        currentProductViewModel?.shareInTwitterActivity()
    }

    func nativeShareInEmail() {
        currentProductViewModel?.shareInEmail(.Top)
    }

    func nativeShareInWhatsApp() {
        currentProductViewModel?.shareInWhatsappActivity()
    }
}


// MARK: - Tracking

extension CarouselMovement {
    var visitUserAction: ProductVisitUserAction {
        switch self {
        case .Tap:
            return .Tap
        case .SwipeLeft:
            return .SwipeLeft
        case .SwipeRight:
            return .SwipeRight
        case .Initial:
            return .None
        }
    }
}
