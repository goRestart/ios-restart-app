//
//  MainProductListView.swift
//  LetGo
//
//  Created by Albert Hernández López on 22/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ProductListViewLocationDelegate {
    func mainProductListView(mainProductListView: MainProductListView, didFailRequestingLocationServices status: LocationServiceStatus)
    func mainProductListView(mainProductListView: MainProductListView, didTimeOutRetrievingLocation timeout: NSTimeInterval)
}

class MainProductListView: ProductListView, MainProductListViewModelDelegate {

    // Delegate
    var locationDelegate: ProductListViewLocationDelegate?

    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        var viewModel = MainProductListViewModel()
        super.init(viewModel: viewModel, coder: aDecoder)
        viewModel.delegate = self
        viewModel.mainProductListViewModelDelegate = self
    }
    
//    // MARK: - ProductListViewModelDelegate
//    
//    override func viewModel(viewModel: ProductListViewModel, didStartRetrievingProductsPage page: UInt) {
//        super.viewModel(viewModel, didStartRetrievingProductsPage: page)
//    }
//    
//    override func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError) {
//        super.viewModel(viewModel, didFailRetrievingProductsPage: page, error: error)
//    }
//    
//    override func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, atIndexPaths indexPaths: [NSIndexPath]) {
//        super.viewModel(viewModel, didSucceedRetrievingProductsPage: page, atIndexPaths: indexPaths)
//    }
    
    // MARK: - MainProductListViewModelDelegate
    
    func viewModel(viewModel: MainProductListViewModel, didFailRequestingLocationServices status: LocationServiceStatus) {
        locationDelegate?.mainProductListView(self, didFailRequestingLocationServices: status)
    }
    
    func viewModel(viewModel: MainProductListViewModel, didTimeOutRetrievingLocation timeout: NSTimeInterval) {
        locationDelegate?.mainProductListView(self, didTimeOutRetrievingLocation: timeout)
    }
}