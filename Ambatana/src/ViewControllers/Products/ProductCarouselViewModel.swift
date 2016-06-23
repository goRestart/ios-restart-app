//
//  ProductCarouselViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ProductCarouselViewModelDelegate: BaseViewModelDelegate {
    func vmReloadData()
}

enum CarouselMovement {
    case Tap, SwipeLeft, SwipeRight, Initial, Auto
}

class ProductCarouselViewModel: BaseViewModel {

    private let previousImagesToPrefetch = 1
    private let nextImagesToPrefetch = 3

    var currentProductViewModel: ProductViewModel?
    var startIndex: Int
    var initialThumbnail: UIImage?
    weak var delegate: ProductCarouselViewModelDelegate?
    
    var objectCount: Int {
        return productListViewModel?.numberOfProducts ?? 0
    }

    var shouldShowOnboarding: Bool {
        return !KeyValueStorage.sharedInstance[.didShowProductDetailOnboarding]
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

    var autoSwitchToNextEnabled: Bool {
        guard let myUserId = myUserRepository.myUser?.objectId,
            userProductListRequester = productListRequester as? UserProductListRequester,
            requesterUserId = userProductListRequester.userObjectId else { return true }
        return myUserId != requesterUserId
    }

    private var productListRequester: ProductListRequester?
    private var productListViewModel: ProductListViewModel?
    private var productsViewModels: [String: ProductViewModel] = [:]
    private let myUserRepository: MyUserRepository


    // MARK: - Init
    convenience init(productListVM: ProductListViewModel, index: Int, thumbnailImage: UIImage?,
         productListRequester: ProductListRequester?) {
        let myUserRepository = Core.myUserRepository
        self.init(myUserRepository: myUserRepository, productListVM: productListVM, index: index,
                  thumbnailImage: thumbnailImage, productListRequester: productListRequester)
    }

    init(myUserRepository: MyUserRepository, productListVM: ProductListViewModel, index: Int, thumbnailImage: UIImage?,
         productListRequester: ProductListRequester?) {
        self.myUserRepository = myUserRepository
        self.startIndex = index
        self.productListViewModel = productListVM
        self.initialThumbnail = thumbnailImage
        self.productListRequester = productListRequester
        super.init()
        self.productListViewModel?.dataDelegate = self
        self.currentProductViewModel = viewModelAtIndex(index)
    }
    
    
    // MARK: - Public Methods
    
    func moveToProductAtIndex(index: Int, delegate: ProductViewModelDelegate, movement: CarouselMovement) {
        guard let viewModel = viewModelAtIndex(index) else { return }
        currentProductViewModel?.active = false
        currentProductViewModel = viewModel
        currentProductViewModel?.delegate = delegate
        currentProductViewModel?.active = true
        currentProductViewModel?.trackVisit(movement.visitUserAction)

        prefetchImages(index)
        prefetchNeighborsImages(index, movement: movement)
    }

    func productAtIndex(index: Int) -> Product? {
        guard 0..<objectCount ~= index else { return nil }
        return productListViewModel?.products[index]
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
        return ProductViewModel(product: product, thumbnailImage: nil)
    }

    func setCurrentItemIndex(index: Int) {
        productListViewModel?.setCurrentItemIndex(index)
    }

    func openProductOwnerProfile() {
        currentProductViewModel?.openProductOwnerProfile()
    }

    func didTapMoreInfoBar() {
        currentProductViewModel?.trackVisitMoreInfo()
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


// MARK: > ProductListViewModelDataDelegate

extension ProductCarouselViewModel: ProductListViewModelDataDelegate {
    func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                       error: RepositoryError) {}
    
    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt,
                       hasProducts: Bool) {
        delegate?.vmReloadData()
    }
    
    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?) {}
}


// MARK: > Image PreCaching

extension ProductCarouselViewModel {
    func prefetchNeighborsImages(index: Int, movement: CarouselMovement) {
        let range: Range<Int>
        switch movement {
        case .Initial:
            range = (index-previousImagesToPrefetch)...(index+nextImagesToPrefetch)
        case .Auto, .Tap, .SwipeRight:
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


// MARK: - Tracking

extension CarouselMovement {
    var visitUserAction: ProductVisitUserAction {
        switch self {
        case .Tap:
            return .Tap
        case .Auto:
            return .Automatic
        case .SwipeLeft:
            return .SwipeLeft
        case .SwipeRight:
            return .SwipeRight
        case .Initial:
            return .None
        }
    }
}
