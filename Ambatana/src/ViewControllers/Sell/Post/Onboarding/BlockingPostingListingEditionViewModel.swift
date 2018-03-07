//
//  BlockingPostingListingEditionViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 07/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class BlockingPostingListingEditionViewModel: BaseViewModel {
    
    enum ListingEditionState: Equatable {
        case updatingListing
        case success
        case error
        
        var message: String {
            switch self {
            case .updatingListing, .success:
                return ""
            case .error:
                return LGLocalizedString.productPostGenericError
            }
        }
    }
    
    private let listingRepository: ListingRepository
    private let listingParams: ListingEditionParams
    
    var state = Variable<ListingEditionState?>(nil)
    private var updatedListing: Listing?
    
    weak var navigator: BlockingPostingNavigator?
    
    
    // MARK: - Lifecycle

    convenience init(listingParams: ListingEditionParams) {
        self.init(listingRepository: Core.listingRepository,
                  listingParams: listingParams)
    }

    init(listingRepository: ListingRepository,
         listingParams: ListingEditionParams) {
        self.listingRepository = listingRepository
        self.listingParams = listingParams
    }

    
    // MARK: - Requests
    
    func updateListing() {
        state.value = .updatingListing
        listingRepository.update(listingParams: listingParams) { [weak self] result in
            guard let strongSelf = self else { return }
            if let responseListing = result.value {
                strongSelf.updatedListing = responseListing
                strongSelf.state.value = .success
            } else if let _ = result.error {
                strongSelf.state.value = .error
            }
        }
    }
    
    
    // MARK: - Navigation
    
    func openListingPosted() {
        guard let listing = self.updatedListing else { return }
        navigator?.openListingPosted(listing: listing)
    }
    
    func closeButtonAction() {
        navigator?.closePosting()
    }
}
