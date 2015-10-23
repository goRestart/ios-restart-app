//
//  MainProductListView.swift
//  LetGo
//
//  Created by Albert Hernández López on 22/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class MainProductListView: ProductListView {

    // View Model
    private var mainProductListViewModel: MainProductListViewModel
    
    // MARK: - Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        mainProductListViewModel = MainProductListViewModel()
        
        super.init(viewModel: mainProductListViewModel, coder: aDecoder)
        mainProductListViewModel.dataDelegate = self
        collectionViewFooterHeight = 80 // safety area for floating sell button
    }
    
    // MARK: - ProductListViewModelDataDelegate
    
    public override func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath]) {

        // If it's the first page with no results
        if page == 0 && !hasProducts {
            
            // Set the error state
            let errBgColor = UIColor(patternImage: UIImage(named: "placeholder_pattern")!)
            let errBorderColor = StyleHelper.lineColor
            let errImage: UIImage?
            let errTitle: String?
            let errBody: String?

            // Search
            if viewModel.queryString != nil {
                errImage = UIImage(named: "err_search_no_products")
                errTitle = NSLocalizedString("product_search_no_products_title", comment: "")
                errBody = NSLocalizedString("product_search_no_products_body", comment: "")
            }
            // Listing
            else {
                errImage = UIImage(named: "err_list_no_products")
                errTitle = NSLocalizedString("product_list_no_products_title", comment: "")
                errBody = NSLocalizedString("product_list_no_products_body", comment: "")
            }
            
            state = .ErrorView(errBgColor: errBgColor, errBorderColor: errBorderColor, errImage: errImage, errTitle: errTitle, errBody: errBody, errButTitle: nil, errButAction: nil)
            
            // Notify the delegate
            delegate?.productListView(self, didSucceedRetrievingProductsPage: page, hasProducts: hasProducts)
        }
        // Otherwise (has results), let super work
        else {
            super.viewModel(viewModel, didSucceedRetrievingProductsPage: page, hasProducts: hasProducts, atIndexPaths: indexPaths)
        }
    }
    
    public override func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool, error: ProductsRetrieveServiceError) {

        // If it's the first page & we have no data
        if page == 0 && !hasProducts {
            
            // Set the error state
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

        super.viewModel(viewModel, didFailRetrievingProductsPage: page, hasProducts: hasProducts, error: error)
    }
}