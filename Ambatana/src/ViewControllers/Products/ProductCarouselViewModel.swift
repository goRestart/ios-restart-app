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

class ProductCarouselViewModel: BaseViewModel {

    var currentProductViewModel: ProductViewModel?
    var startIndex: Int
    var initialThumbnail: UIImage?
    weak var delegate: ProductCarouselViewModelDelegate?
    
    private var productListRequester: ProductListRequester?
    private var productListViewModel: ProductListViewModel?
    private var productsViewModels: [String: ProductViewModel] = [:]
    
    var objectCount: Int {
        return productListViewModel?.numberOfProducts ?? 0
    }

    var onboardingState: OnboardingState? {
        if !UserDefaultsManager.sharedInstance.loadDidShowProductDetailOnboarding() {
            // if wasn't shown before, we need to show the WHOLE Onboarding
            return .Fingers
        } else {
            return currentProductViewModel?.onboardingState
        }
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
    

    // MARK: - Init
    
    init(productListVM: ProductListViewModel, index: Int, thumbnailImage: UIImage?,
         productListRequester: ProductListRequester?) {
        self.startIndex = index
        self.productListViewModel = productListVM
        self.initialThumbnail = thumbnailImage
        self.productListRequester = productListRequester
        super.init()
        self.productListViewModel?.dataDelegate = self
        self.currentProductViewModel = viewModelAtIndex(index)
    }
    
    
    // MARK: - Public Methods
    
    func moveToProductAtIndex(index: Int, delegate: ProductViewModelDelegate) {
        guard let viewModel = viewModelAtIndex(index) else { return }
        currentProductViewModel?.didSetActive(false)
        currentProductViewModel = viewModel
        currentProductViewModel?.delegate = delegate
        currentProductViewModel?.didSetActive(true)
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
