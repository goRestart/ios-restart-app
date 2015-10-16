//
//  ProfileProductListView.swift
//  LetGo
//
//  Created by AHL on 25/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum ProfileProductListViewType {
    case Selling
    case Sold
}

public class ProfileProductListView: ProductListView {

    var profileProductListViewModel: ProfileProductListViewModel
    
    public var user: User? {
        get {
            return profileProductListViewModel.user
        }
        set {
            profileProductListViewModel.user = newValue
        }
    }
    public var type: ProfileProductListViewType {
        get {
            return profileProductListViewModel.type
        }
        set {
            profileProductListViewModel.type = newValue
        }
    }
    
    // MARK: - Lifecycle
    
    public required init(coder aDecoder: NSCoder) {
        self.profileProductListViewModel = ProfileProductListViewModel()
        super.init(viewModel: self.profileProductListViewModel, coder: aDecoder)
        self.profileProductListViewModel.dataDelegate = self
        collectionViewFooterHeight = 80 // safety area for floating sell button
    }
    
    // MARK: - ProductListViewModelDataDelegate

    public override func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath]) {
        
        // If it's the first page with no results & notify the delegate
        let isFirstPageWithNoResults = ( page == 0 && !hasProducts )
        if isFirstPageWithNoResults {
            
            let errBody: String = LGLocalizedString.profileNoProducts
            state = .ErrorView(errBgColor: nil, errBorderColor: nil, errImage: nil, errTitle: nil, errBody: errBody, errButTitle: nil, errButAction: nil)

            delegate?.productListView(self, didSucceedRetrievingProductsPage: page, hasProducts: hasProducts)
        }
        // Otherwise (has results), let super work
        else {
            super.viewModel(viewModel, didSucceedRetrievingProductsPage: page, hasProducts: hasProducts, atIndexPaths: indexPaths)
        }
    }

}
