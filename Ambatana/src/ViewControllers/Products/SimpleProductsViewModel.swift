//
//  ProductsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 25/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum SimpleProductsListMode {
    case standard
    case notFound

    var hideBottomBar: Bool {
        switch self {
        case .standard, .notFound:
            return true
        }
    }
}

class SimpleProductsViewModel: BaseViewModel {

    weak var navigator: SimpleProductsNavigator?

    let title: String
    let productVisitSource: EventParameterProductVisitSource
    let productListRequester: ProductListRequester
    let productListViewModel: ProductListViewModel
    let featureFlags: FeatureFlaggeable
    let productsListMode: SimpleProductsListMode

    convenience init(relatedProductId: String,
                     productVisitSource: EventParameterProductVisitSource,
                     productsListMode: SimpleProductsListMode) {
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let itemsPerPage = show3Columns ? Constants.numProductsPerPageBig : Constants.numProductsPerPageDefault
        let requester = RelatedProductListRequester(productId: relatedProductId, itemsPerPage: itemsPerPage)
        self.init(requester: requester,
                  title: LGLocalizedString.relatedItemsTitle,
                  productVisitSource: productVisitSource,
                  productsListMode: productsListMode)
    }

    convenience init(requester: ProductListRequester,
                     title: String,
                     productVisitSource: EventParameterProductVisitSource,
                     productsListMode: SimpleProductsListMode) {
        self.init(requester: requester,
                  listings: nil,
                  title: title,
                  productVisitSource: productVisitSource,
                  featureFlags: FeatureFlags.sharedInstance,
                  productsListMode: productsListMode)
    }

    convenience init(requester: ProductListRequester,
                     listings: [Listing],
                     productVisitSource: EventParameterProductVisitSource,
                     productsListMode: SimpleProductsListMode) {
        self.init(requester: requester,
                  listings: listings,
                  title: LGLocalizedString.relatedItemsTitle,
                  productVisitSource: productVisitSource,
                  featureFlags: FeatureFlags.sharedInstance,
                  productsListMode: productsListMode)
    }

    init(requester: ProductListRequester, listings: [Listing]?, title: String, productVisitSource: EventParameterProductVisitSource,
         featureFlags: FeatureFlaggeable, productsListMode: SimpleProductsListMode) {
        self.title = title
        self.productVisitSource = productVisitSource
        self.productListRequester = requester
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        self.productListViewModel = ProductListViewModel(requester: requester, listings: listings, numberOfColumns: columns)
        self.featureFlags = featureFlags
        self.productsListMode = productsListMode
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
        guard let listing = viewModel.listingAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let data = ListingDetailData.listingList(listing: listing, cellModels: cellModels,
                                                 requester: productListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame, showRelated: false, index: index)
        navigator?.openListing(data, source: productVisitSource, actionOnFirstAppear: .nonexistent)
    }

    func vmProcessReceivedProductPage(_ products: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        return products
    }
    func vmDidSelectSellBanner(_ type: String) {}
    func vmDidSelectCollection(_ type: CollectionCellType) {}
}
