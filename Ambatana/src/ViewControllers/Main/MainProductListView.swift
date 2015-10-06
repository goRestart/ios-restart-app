//
//  MainProductListView.swift
//  LetGo
//
//  Created by Albert Hernández López on 22/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class MainProductListView: ProductListView {

    // MARK: - Lifecycle
    
    public required init(coder aDecoder: NSCoder) {
        var viewModel = MainProductListViewModel()
        super.init(viewModel: viewModel, coder: aDecoder)
        viewModel.dataDelegate = self
        collectionViewFooterHeight = 80 // safety area for floating sell button
    }
    
    // MARK: - ProductListViewModelDataDelegate
    
    public override func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, atIndexPaths indexPaths: [NSIndexPath]) {

        // If it's the first page with no results
        if page == 0 && viewModel.numberOfProducts == 0 {
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
            
            state = .ErrorView(errBgColor: nil, errBorderColor: nil, errImage: nil, errTitle: nil, errBody: errBody, errButTitle: errButTitle, errButAction: errButAction)
            
            // Notify the delegate
            delegate?.productListView(self, didSucceedRetrievingProductsPage: page)
        }
        // Otherwise (has results), let super work
        else {
            super.viewModel(viewModel, didSucceedRetrievingProductsPage: page, atIndexPaths: indexPaths)
        }
    }
    
    public override func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError) {

        // If it's the first page & we have no data, the set the error state
        if page == 0 && viewModel.numberOfProducts == 0 {
            let errBgColor: UIColor?
            let errBorderColor: UIColor?
            let errImage: UIImage?
            let errTitle: String?
            let errBody: String?
            let errButTitle: String?
            let errButAction: (() -> Void)?
            
            switch error {
            case .Network:
                errImage = UIImage(named: "err_network")
                errTitle = NSLocalizedString("common_error_title", comment: "")
                errBody = NSLocalizedString("common_error_network_body", comment: "")
                errButTitle = NSLocalizedString("common_error_retry_button", comment: "")
            case .Internal, .Forbidden:
                errImage = UIImage(named: "err_generic")
                errTitle = NSLocalizedString("common_error_title", comment: "")
                errBody = NSLocalizedString("common_error_generic_body", comment: "")
                errButTitle = NSLocalizedString("common_error_retry_button", comment: "")
            }
            errBgColor = UIColor(patternImage: UIImage(named: "placeholder_pattern")!)
            errBorderColor = StyleHelper.lineColor
            
            errButAction = {
                self.refresh()
            }
            
            state = .ErrorView(errBgColor: errBgColor, errBorderColor: errBorderColor, errImage: errImage, errTitle: errTitle, errBody: errBody, errButTitle: errButTitle, errButAction: errButAction)
        }

        super.viewModel(viewModel, didFailRetrievingProductsPage: page, error: error)
    }
}