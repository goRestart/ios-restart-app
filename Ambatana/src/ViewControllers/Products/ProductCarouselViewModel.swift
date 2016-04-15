//
//  ProductCarouselViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductCarouselViewModel: BaseViewModel {
    var products: [Product] = []
    var productFilters: ProductFilters?
    var productsViewModels: [ProductViewModel] = []
    
    // Init with an array will show the array and use the filters to load more items
    init(products: [Product], filters: ProductFilters?) {
        self.products = products
        super.init()
        buildViewModels()
    }
    
    // Init with a product will show related products
    init(product: Product) {
        self.products = [product]
    }
    
    private func buildViewModels() {
        products.forEach {
            productsViewModels.append(ProductViewModel(product: $0, thumbnailImage: nil))
        }
    }
    
    func productAtIndex(index: Int) -> Product? {
        guard 0..<products.count ~= index else { return nil }
        return products[index]
    }
}
