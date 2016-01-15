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
    var mainProductListViewModel: MainProductListViewModel
    
    
    // MARK: - Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        self.mainProductListViewModel = MainProductListViewModel()
        
        super.init(viewModel: mainProductListViewModel, coder: aDecoder)
        mainProductListViewModel.dataDelegate = self
    }


    // MARK: - Public methods

    public func sessionDidChange() {
        mainProductListViewModel.sessionDidChange()
    }
    
    
    // MARK: - ProductListViewModelDataDelegate
    
    public override func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt,
        hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath]) {
            
            // If it's the first page with no results
            if page == 0 && !hasProducts {
                
                // Set the error state
                let errBgColor = UIColor(patternImage: UIImage(named: "placeholder_pattern")!)
                let errBorderColor = StyleHelper.lineColor
                let errImage: UIImage?
                let errTitle: String?
                let errBody: String?
                
                // Search
                if viewModel.queryString != nil || viewModel.hasFilters {
                    errImage = UIImage(named: "err_search_no_products")
                    errTitle = LGLocalizedString.productSearchNoProductsTitle
                    errBody = LGLocalizedString.productSearchNoProductsBody
                } else {
                    // Listing
                    errImage = UIImage(named: "err_list_no_products")
                    errTitle = LGLocalizedString.productListNoProductsTitle
                    errBody = LGLocalizedString.productListNoProductsBody
                }
                
                state = .ErrorView(errBgColor: errBgColor, errBorderColor: errBorderColor, errImage: errImage,
                    errTitle: errTitle, errBody: errBody, errButTitle: nil, errButAction: nil)
                
                // Notify the delegate
                delegate?.productListView(self, didSucceedRetrievingProductsPage: page, hasProducts: hasProducts)
            } else {
                // Otherwise (has results), let super work
                super.viewModel(viewModel, didSucceedRetrievingProductsPage: page, hasProducts: hasProducts,
                    atIndexPaths: indexPaths)
            }
    }
    
    public override func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt,
        hasProducts: Bool, error: RepositoryError) {

            defer {
                super.viewModel(viewModel, didFailRetrievingProductsPage: page, hasProducts: hasProducts, error: error)
            }

            guard page == 0 && !hasProducts else { return }

            // If it's the first page & we have no data
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
                errTitle = LGLocalizedString.commonErrorTitle
                errBody = LGLocalizedString.commonErrorNetworkBody
                errButTitle = LGLocalizedString.commonErrorRetryButton
            case .Internal, .Unauthorized, .NotFound:
                errImage = UIImage(named: "err_generic")
                errTitle = LGLocalizedString.commonErrorTitle
                errBody = LGLocalizedString.commonErrorGenericBody
                errButTitle = LGLocalizedString.commonErrorRetryButton
            }
            errBgColor = UIColor(patternImage: UIImage(named: "placeholder_pattern")!)
            errBorderColor = StyleHelper.lineColor

            errButAction = {
                self.refresh()
            }

            state = .ErrorView(errBgColor: errBgColor, errBorderColor: errBorderColor, errImage: errImage,
                errTitle: errTitle, errBody: errBody, errButTitle: errButTitle, errButAction: errButAction)
    }
}