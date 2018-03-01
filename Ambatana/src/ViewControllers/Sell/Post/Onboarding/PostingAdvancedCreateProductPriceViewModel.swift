//
//  PostingAdvancedCreateProductPriceViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 19/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

class PostingAdvancedCreateProductPriceViewModel: BaseViewModel {
    
    private let listingRepository: ListingRepository
    private let listingCreationParams: ListingCreationParams
    
    weak var navigator: PostingAdvancedCreateProductNavigator?

    
    // MARK: - Lifecycle
    
    convenience init(listingCreationParams: ListingCreationParams,
                     postState: PostListingState) {
        self.init(listingRepository: Core.listingRepository,
                  listingCreationParams: listingCreationParams,
                  postState: postState)
    }
    
    init(listingRepository: ListingRepository,
         listingCreationParams: ListingCreationParams,
         postState: PostListingState) {
        self.listingRepository = listingRepository
        self.listingCreationParams = listingCreationParams
        
        super.init()
    }
    
    
    // MARK: - Navigation
    
    func openCongratulationsScreen() {
        navigator?.openPrice()
    }
}
