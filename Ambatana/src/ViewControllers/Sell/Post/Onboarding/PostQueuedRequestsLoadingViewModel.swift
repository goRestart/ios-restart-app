//
//  PostQueuedRequestsLoadingViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 04/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class PostQueuedRequestsLoadingViewModel: BaseViewModel {
    
    private let listingRepository: ListingRepository
    private let fileRepository: FileRepository
    private let images: [UIImage]
    //private let trackingInfo: PostListingTrackingInfo
    private var listingResult: ListingResult?
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    //var finishRequest = Variable<Bool?>(false)
    
    
    // MARK: - Lifecycle
    
    convenience init(images: [UIImage]) {
        self.init(listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  images: images)
    }
    
    init(listingRepository: ListingRepository,
         fileRepository: FileRepository,
         images: [UIImage]) {
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.images = images
        super.init()
    }
    
    func createListing() {
//        fileRepository.upload(images, progress: nil) { [weak self] result in
//        if let images = result.value {
//        guard let strongSelf = self else { return }
//        guard let images = strongSelf.state.value.lastImagesUploadResult?.value,
//        let listingCreationParams = strongSelf.makeListingParams(images: images) else { return }
//
//        self?.listingRepository.create(listingParams: listingCreationParams) { [weak self] result in
//        if let postedListing = result.value {
//        //self?.trackPostSellComplete(postedListing: postedListing)
//        } else if let error = result.error {
//        //self?.trackPostSellError(error: error)
//        }
//        self?.updateStatusAfterPosting(status: ListingPostedStatus(listingResult: result))
//        }
//        } else if let error = result.error {
//        guard let strongSelf = self else { return }
//        strongSelf.state.value = strongSelf.state.value.updating(uploadError: error)
//        }
//        }
    }
//
//    func nextStep() {
//        guard let result = listingResult else {
//            navigator?.cancelPostListing() // It should never happen
//            return }
//        navigator?.showConfirmation(listingResult: result, trackingInfo: trackingInfo, modalStyle: false)
//    }
}
