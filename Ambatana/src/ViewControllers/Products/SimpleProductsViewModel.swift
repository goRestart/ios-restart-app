//
//  ProductsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 25/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class SimpleProductsViewModel: BaseViewModel {

    weak var navigator: SimpleProductsNavigator?

    let title: String
    let productVisitSource: EventParameterProductVisitSource
    let productListRequester: ProductListRequester
    let productListViewModel: ProductListViewModel
    let featureFlags: FeatureFlaggeable

    convenience init(relatedProductId: String, productVisitSource: EventParameterProductVisitSource) {
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let itemsPerPage = show3Columns ? Constants.numProductsPerPageBig : Constants.numProductsPerPageDefault
        let requester = RelatedProductListRequester(productId: relatedProductId, itemsPerPage: itemsPerPage)
        self.init(requester: requester, title: LGLocalizedString.relatedItemsTitle, productVisitSource: productVisitSource)
    }

    convenience init(requester: ProductListRequester, title: String, productVisitSource: EventParameterProductVisitSource) {
        self.init(requester: requester, title: title, productVisitSource: productVisitSource, featureFlags: FeatureFlags.sharedInstance)
    }

    init(requester: ProductListRequester, title: String, productVisitSource: EventParameterProductVisitSource,
         featureFlags: FeatureFlaggeable) {
        self.title = title
        self.productVisitSource = productVisitSource
        self.productListRequester = requester
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        self.productListViewModel = ProductListViewModel(requester: requester, numberOfColumns: columns)
        self.featureFlags = featureFlags
        super.init()
        productListViewModel.dataDelegate = self
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            productListViewModel.refresh()
        }
    }

    override func backButtonPressed() -> Bool {
        guard let navigator = navigator else { return false }
        navigator.closeSimpleProducts()
        return true
    }
}


extension SimpleProductsViewModel: ProductListViewModelDataDelegate {
    func productListMV(_ viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                       error: RepositoryError) {

    }
    func productListVM(_ viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool) {

    }
    func productListVM(_ viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?) {
        guard let product = viewModel.productAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let data = ProductDetailData.productList(product: product, cellModels: cellModels,
                                                 requester: productListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame, showRelated: false, index: index)
        navigator?.openProduct(data, source: productVisitSource,
                               showKeyboardOnFirstAppearIfNeeded: false)
    }

    func vmProcessReceivedProductPage(_ products: [ProductCellModel], page: UInt) -> [ProductCellModel] {
        return products
    }
    func vmDidSelectSellBanner(_ type: String) {}
    func vmDidSelectCollection(_ type: CollectionCellType) {}
}
