//
//  MainProductListView.swift
//  LetGo
//
//  Created by Albert Hernández López on 22/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public protocol ProductListViewLocationDelegate {
    func mainProductListView(mainProductListView: MainProductListView, didFailRequestingLocationServices status: LocationServiceStatus)
    func mainProductListView(mainProductListView: MainProductListView, didTimeOutRetrievingLocation timeout: NSTimeInterval)
}

public class MainProductListView: ProductListView, MainProductListViewModelLocationDelegate {

    // Delegate
    public var locationDelegate: ProductListViewLocationDelegate?

    // MARK: - Lifecycle
    
    public required init(coder aDecoder: NSCoder) {
        var viewModel = MainProductListViewModel()
        super.init(viewModel: viewModel, coder: aDecoder)
        viewModel.dataDelegate = self
        viewModel.locationDelegate = self
    }
    
    // MARK: - ProductListViewModelDataDelegate
    
    public override func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, atIndexPaths indexPaths: [NSIndexPath]) {

        // If it's the first page with no results
        let isFirstPageWithNoResults = ( page == 0 && indexPaths.isEmpty )
        if isFirstPageWithNoResults {

            let errBody: String?
            let errButTitle: String?
            let errButAction: (() -> Void)?
            
            // Search
            if viewModel.queryString != nil {
                errBody = NSLocalizedString("product_list_search_no_products_label", comment: "")
                errButTitle = nil
                errButAction = nil
            }
            // Listing
            else {
                errBody = NSLocalizedString("product_list_no_products_label", comment: "")
                errButTitle = NSLocalizedString("product_list_no_products_button", comment: "")
                errButAction = {
                    self.refresh()
                }
            }
            
            state = .ErrorView(errImage: nil, errTitle: nil, errBody: errBody, errButTitle: errButTitle, errButAction: errButAction)
        }
        // Otherwise (has results), let super work
        else {
            super.viewModel(viewModel, didSucceedRetrievingProductsPage: page, atIndexPaths: indexPaths)
        }
    }
    
    // MARK: - MainProductListViewModelLocationDelegate
    
    public func viewModel(viewModel: MainProductListViewModel, didFailRequestingLocationServices status: LocationServiceStatus) {
        locationDelegate?.mainProductListView(self, didFailRequestingLocationServices: status)
    }
    
    public func viewModel(viewModel: MainProductListViewModel, didTimeOutRetrievingLocation timeout: NSTimeInterval) {
        locationDelegate?.mainProductListView(self, didTimeOutRetrievingLocation: timeout)
    }
}