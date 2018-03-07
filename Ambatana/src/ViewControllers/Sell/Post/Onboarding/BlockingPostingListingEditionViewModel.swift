//
//  BlockingPostingListingEditionViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 07/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

class BlockingPostingListingEditionViewModel: BaseViewModel {

    private let listingRepository: ListingRepository
    private let listingParams: ListingEditionParams
    
    //private var listingResult: ListingResult?
    
    weak var navigator: BlockingPostingNavigator?
    //private let disposeBag = DisposeBag()
    
    //var finishRequest = Variable<Bool?>(false)
    
    
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

    func updateListing() {
        listingRepository.update(listingParams: listingParams) { result in
            if let responseListing = result.value {
                self.navigator?.openListingPosted(listing: responseListing)
            } else if let error = result.error {
                print("ko")
            }
        }
//        listingRepository.create(listingParams: listingParams) { [weak self] result in
//            if let listing = result.value, let trackingInfo = self?.trackingInfo {
//                self?.trackPost(withListing: listing, trackingInfo: trackingInfo)
//            } else if let error = result.error {
//                self?.trackPostSellError(error: error)
//            }
//            self?.listingResult = result
//            self?.finishRequest.value = true
//        }
    }
}
