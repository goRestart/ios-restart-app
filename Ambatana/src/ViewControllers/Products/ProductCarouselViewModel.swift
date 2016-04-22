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
    init(productListVM: ProductListViewModel, index: Int, thumbnailImage: UIImage?) {
        super.init()
        self.productsViewModels = buildViewModels(products)
        self.currentProductViewModel = self.productsViewModels.first
    }

    // Init with a product will show related products
    convenience init(product: Product) {
        let viewModel = ProductViewModel(product: product, thumbnailImage: nil)
        self.init(productViewModel: viewModel)
    }
    
    init(productViewModel: ProductViewModel) {
        self.currentProductViewModel = productViewModel
        self.productsViewModels = [productViewModel]
        super.init()
    }

    private func buildViewModels(products: [Product]) -> [ProductViewModel] {
        return products.map {
            return ProductViewModel(product: $0, thumbnailImage: nil)
        }
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
    
    func thumbnailAtIndex(index: Int) -> UIImage? {
        guard 0..<productsViewModels.count ~= index else { return nil }
        return productsViewModels[index].thumbnailImage
    }
    
    func viewModelAtIndex(index: Int) -> ProductViewModel? {
        guard 0..<productsViewModels.count ~= index else { return nil }
        return productsViewModels[index]
    }
    
    func viewModelForProduct(product: Product) -> ProductViewModel {
        return ProductViewModel(product: product, thumbnailImage: nil)
    }
}
