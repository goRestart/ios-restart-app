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
    case Favorites
}

public class ProfileProductListView: ProductListView {
    var profileProductListViewModel: ProfileProductListViewModel


    // MARK: - Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        self.profileProductListViewModel = ProfileProductListViewModel()
        super.init(viewModel: self.profileProductListViewModel, coder: aDecoder)
        self.profileProductListViewModel.delegate = self
        self.shouldScrollToTopOnFirstPageReload = false
    }

    override func setupUI() {
        super.setupUI()

        // Remove pull to refresh
        refreshControl?.removeFromSuperview()
    }
    

    // MARK: - ProductListViewModelDataDelegate

    public override func vmDidSucceedRetrievingProductsPage(page: UInt,
        hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath]) {

            // If it's the first page with no results & notify the delegate
            let isFirstPageWithNoResults = ( page == 0 && !hasProducts )
            if isFirstPageWithNoResults {
                let errTitle = profileProductListViewModel.emptyStateTitle
                let errButTitle = profileProductListViewModel.emptyStateButtonTitle
                let errButAction = profileProductListViewModel.emptyStateButtonAction

                profileProductListViewModel.state = .ErrorView(errBgColor: nil, errBorderColor: nil, errContainerColor: nil, errImage: nil,
                                   errTitle: errTitle, errBody: nil, errButTitle: errButTitle, errButAction: errButAction)
                delegate?.productListView(self, didSucceedRetrievingProductsPage: page, hasProducts: hasProducts)
            }
            // Otherwise (has results), let super work
            else {
                super.vmDidSucceedRetrievingProductsPage(page, hasProducts: hasProducts, atIndexPaths: indexPaths)
            }
    }

    public override func vmDidFailRetrievingProductsPage(page: UInt,
        hasProducts: Bool, error: RepositoryError) {

        defer {
            super.vmDidFailRetrievingProductsPage(page, hasProducts: hasProducts, error: error)
        }

        guard page == 0 && !hasProducts else { return }

        // If it's the first page & we have no data
        // Set the error state
        let errBgColor: UIColor? = nil
        let errBorderColor: UIColor? = nil
        let errContainerColor: UIColor? = nil
        let errImage: UIImage? = nil
        let errTitle: String?
        let errBody: String?
        let errButTitle: String?
        let errButAction: (() -> Void)?

        switch error {
        case .Network:
            errTitle = LGLocalizedString.commonErrorTitle
            errBody = LGLocalizedString.commonErrorNetworkBody
            errButTitle = LGLocalizedString.commonErrorRetryButton
        case .Internal, .Unauthorized, .NotFound:
            errTitle = LGLocalizedString.commonErrorTitle
            errBody = LGLocalizedString.commonErrorGenericBody
            errButTitle = LGLocalizedString.commonErrorRetryButton
        }

        errButAction = {
            self.refresh()
        }

        profileProductListViewModel.state = .ErrorView(errBgColor: errBgColor, errBorderColor: errBorderColor, errContainerColor: errContainerColor,
                           errImage: errImage, errTitle: errTitle, errBody: errBody, errButTitle: errButTitle,
                           errButAction: errButAction)
    }
}


// MARK: - Public methods

extension ProfileProductListView {
    func switchViewModel(viewModel: ProfileProductListViewModel) {
        profileProductListViewModel = viewModel
        super.switchViewModel(viewModel)
    }
}
