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
        
        var isAnimated: Bool {
            return self == .updatingListing
        }
        
        var isError: Bool {
            return self == .error
        }
    }
    
    private let listingRepository: ListingRepository
    private let listingParams: ListingEditionParams
    private let images: [UIImage]
    
    var state = Variable<ListingEditionState?>(nil)
    private var updatedListing: Listing?
    
    weak var navigator: BlockingPostingNavigator?
    
    
    // MARK: - Lifecycle

    convenience init(listingParams: ListingEditionParams, images: [UIImage]) {
        self.init(listingRepository: Core.listingRepository,
                  listingParams: listingParams,
                  images: images)
    }

    init(listingRepository: ListingRepository,
         listingParams: ListingEditionParams,
         images: [UIImage]) {
        self.listingRepository = listingRepository
        self.listingParams = listingParams
        self.images = images
    }

    
    // MARK: - Requests
    
    func updateListing() {
        state.value = .updatingListing
        listingRepository.update(listingParams: listingParams) { [weak self] result in
            if let responseListing = result.value {
                self?.updatedListing = responseListing
                self?.state.value = .success
            } else if let _ = result.error {
                self?.state.value = .error
            }
        }
    }
    
    
    // MARK: - Navigation
    
    func openListingPosted() {
        guard let listing = self.updatedListing else { return }
        navigator?.openListingPosted(listing: listing, images: images)
    }
    
    func closeButtonAction() {
        navigator?.closePosting()
    }
}
