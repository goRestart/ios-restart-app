//
//  ProductCarouselViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductCarouselViewModel: BaseViewModel {

    var productFilters: ProductFilters?
    var productsViewModels: [ProductViewModel] = []
    var currentProductViewModel: ProductViewModel?
    
    // Init with an array will show the array and use the filters to load more items
    init(products: [Product], filters: ProductFilters?) {
        self.currentProductViewModel = self.productsViewModels.first
        super.init()
        self.productsViewModels = buildViewModels(products)
    }
    
    private func buildViewModels(products: [Product]) -> [ProductViewModel] {
        return products.map {
            return ProductViewModel(product: $0, thumbnailImage: nil)
        }
    }
    
    // Init with a product will show related products
    init(product: Product) {
        let viewModel = ProductViewModel(product: product, thumbnailImage: nil)
        self.currentProductViewModel = viewModel
        self.productsViewModels = [viewModel]
    }
    
    
    func moveToProductAtIndex(index: Int, delegate: ProductViewModelDelegate) {
        guard let viewModel = viewModelAtIndex(index) else { return }
        currentProductViewModel?.didSetActive(false)
        currentProductViewModel = viewModel
        currentProductViewModel?.delegate = delegate
        currentProductViewModel?.didSetActive(true)
    }
    
    func productAtIndex(index: Int) -> Product? {
        guard 0..<productsViewModels.count ~= index else { return nil }
        return productsViewModels[index].product.value
    }
    
    func viewModelAtIndex(index: Int) -> ProductViewModel? {
        guard 0..<productsViewModels.count ~= index else { return nil }
        return productsViewModels[index]
    }
    
    func viewModelForProduct(product: Product) -> ProductViewModel {
        return ProductViewModel(product: product, thumbnailImage: nil)
    }
}
