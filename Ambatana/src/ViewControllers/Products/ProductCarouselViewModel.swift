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

    var productsViewModels: [String: ProductViewModel] = [:]
    var currentProductViewModel: ProductViewModel?
    var startIndex: Int
    var productListViewModel: ProductListViewModel?
    weak var delegate: ProductCarouselViewModelDelegate?
    
    var objectCount: Int {
        return productListViewModel?.numberOfProducts ?? 0
    }
    
    // Init with an array will show the array and use the filters to load more items
    init(productListVM: ProductListViewModel, index: Int, thumbnailImage: UIImage?) {
        self.startIndex = index
        self.productListViewModel = productListVM
        super.init()
        self.productListViewModel?.dataDelegate = self
        self.currentProductViewModel = viewModelAtIndex(index)
    }

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
        guard 0..<objectCount ~= index else { return nil }
        return viewModelAtIndex(index)?.thumbnailImage
    }
    
    func viewModelAtIndex(index: Int) -> ProductViewModel? {
        guard let product = productAtIndex(index), let productId = product.objectId else { return nil }
        if let vm = productsViewModels[productId] {
            return vm
        }
        let vm = viewModelForProduct(product)
        productsViewModels[productId] = vm
        return vm
    }
    
    func viewModelForProduct(product: Product) -> ProductViewModel {
        return ProductViewModel(product: product, thumbnailImage: nil)
    }
}

extension ProductCarouselViewModel: ProductListViewModelDataDelegate {
    func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                       error: RepositoryError) {}
    
    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool) {
        delegate?.vmReloadData()
    }
    
    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?) {}
}
