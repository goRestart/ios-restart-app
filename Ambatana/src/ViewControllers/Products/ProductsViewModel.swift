//
//  ProductsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 25/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ProductsViewModel: BaseViewModel {

    weak var navigator: ProductListNavigator?

    let productListRequester: ProductListRequester
    let productListViewModel: ProductListViewModel
    let featureFlags: FeatureFlaggeable

    convenience init(relatedProductId: String) {
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let itemsPerPage = show3Columns ? Constants.numProductsPerPageBig : Constants.numProductsPerPageDefault
        let requester = RelatedProductListRequester(productId: relatedProductId, itemsPerPage: itemsPerPage)
        self.init(requester: requester)
    }

    convenience init(requester: ProductListRequester) {
        self.init(requester: requester, featureFlags: FeatureFlags.sharedInstance)
    }

    init(requester: ProductListRequester, featureFlags: FeatureFlaggeable) {
        self.productListRequester = requester
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        self.productListViewModel = ProductListViewModel(requester: requester, numberOfColumns: columns)
        self.featureFlags = featureFlags
        super.init()
        productListViewModel.dataDelegate = self
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            productListViewModel.refresh()
        }
    }

    override func backButtonPressed() -> Bool {
        guard let navigator = navigator else { return false }
        navigator.closeProductList()
        return true
    }
}


extension ProductsViewModel: ProductListViewModelDataDelegate {
    func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                       error: RepositoryError) {

    }
    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool) {

    }
    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?) {
        guard let product = viewModel.productAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let data = ProductDetailData.ProductList(product: product, cellModels: cellModels,
                                                 requester: productListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame, showRelated: false, index: index)
        navigator?.openProduct(data, source: .RelatedProductList)
    }

    func vmProcessReceivedProductPage(products: [ProductCellModel], page: UInt) -> [ProductCellModel] {
        return products
    }
    func vmDidSelectSellBanner(type: String) {}
    func vmDidSelectCollection(type: CollectionCellType) {}
}
