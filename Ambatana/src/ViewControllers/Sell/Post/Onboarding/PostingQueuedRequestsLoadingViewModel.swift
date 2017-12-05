//
//  PostingQueuedRequestsLoadingViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 04/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class PostingQueuedRequestsLoadingViewModel: BaseViewModel {
    
    private let listingRepository: ListingRepository
    private let fileRepository: FileRepository
    private let images: [UIImage]
    private let listingCreationParams: ListingCreationParams
    //private let trackingInfo: PostListingTrackingInfo
    private var listingResult: ListingResult?
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    //var finishRequest = Variable<Bool?>(false)
    
    
    // MARK: - Lifecycle
    
    convenience init(images: [UIImage], listingCreationParams: ListingCreationParams) {
        self.init(listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  images: images,
                  listingCreationParams: listingCreationParams)
    }
    
    init(listingRepository: ListingRepository,
         fileRepository: FileRepository,
         images: [UIImage],
         listingCreationParams: ListingCreationParams) {
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.images = images
        self.listingCreationParams = listingCreationParams
        super.init()
    }
    
    func createListing() {
        fileRepository.upload(images, progress: nil) { [weak self] result in
            if let images = result.value {
                guard let strongSelf = self else { return }
                let updatedParams = strongSelf.listingCreationParams.updating(images: images)
                strongSelf.listingRepository.create(listingParams: updatedParams) { [weak self] result in
                    if let postedListing = result.value {
                        //self?.trackPostSellComplete(postedListing: postedListing)
                    } else if let error = result.error {
                        //self?.trackPostSellError(error: error)
                    }
                    // TODO: Handle UI. self?.updateStatusAfterPosting(status: ListingPostedStatus(listingResult: result))
                }
            } else if let error = result.error {
                guard let strongSelf = self else { return }
                // TODO: Handle UI. strongSelf.state.value = strongSelf.state.value.updating(uploadError: error)
            }
        }
    }
}
