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
    let postOnboardingState: Variable<PostOnboardingListingState>
    let isLoading = Variable<Bool>(false)
    let gotListingCreateResponse = Variable<Bool>(false)
    //private let trackingInfo: PostListingTrackingInfo
    private var listingResult: ListingResult?
    
    weak var navigator: PostingAdvancedCreateProductNavigator?
    private let disposeBag = DisposeBag()
    
    //var finishRequest = Variable<Bool?>(false)
    
    
    // MARK: - Lifecycle
    
    convenience init(images: [UIImage], listingCreationParams: ListingCreationParams, postState: PostListingState) {
        self.init(listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  images: images,
                  listingCreationParams: listingCreationParams,
                  postState: postState)
    }
    
    convenience init(images: [UIImage], listingCreationParams: ListingCreationParams, postState: PostListingState,
                     listingRepository: ListingRepository, fileRepository: FileRepository) {
        self.init(listingRepository: listingRepository,
                  fileRepository: fileRepository,
                  images: images,
                  listingCreationParams: listingCreationParams,
                  postState: postState)
    }
    
    init(listingRepository: ListingRepository,
         fileRepository: FileRepository,
         images: [UIImage],
         listingCreationParams: ListingCreationParams,
         postState: PostListingState) {
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.images = images
        self.listingCreationParams = listingCreationParams

        self.postOnboardingState = Variable<PostOnboardingListingState>(PostOnboardingListingState(postListingState: postState))
        super.init()
    }
    
    func createListingAfterUploadingImages() {
        postOnboardingState.value =  postOnboardingState.value.updatingStepToUploadingImages()
        isLoading.value = true
        
        // TODO: Handle UI
        // TODO: Add tracking
        fileRepository.upload(images, progress: nil) { [weak self] result in
            if let images = result.value {
                guard let strongSelf = self else { return }
                strongSelf.postOnboardingState.value = strongSelf.postOnboardingState.value.updatingStepToImageUploadSuccess()
                let updatedParams = strongSelf.listingCreationParams.updating(images: images)
                strongSelf.listingRepository.create(listingParams: updatedParams) { [weak self] result in
                    if let postedListing = result.value {
                        strongSelf.postOnboardingState.value = strongSelf.postOnboardingState.value.updatingStepToListingCreationSuccess()
                    } else if let error = result.error {
                        strongSelf.postOnboardingState.value = strongSelf.postOnboardingState.value.updatingStepToListingCreationError(error)
                    }
                    strongSelf.gotListingCreateResponse.value = true
                    strongSelf.isLoading.value = false
                }
            } else if let error = result.error {
                guard let strongSelf = self else { return }
                strongSelf.isLoading.value = false
                strongSelf.postOnboardingState.value = strongSelf.postOnboardingState.value.updatingStepToImageUploadError(error)
            }
        }
    }
    
    
    // MARK: - Navigation
    
    func openPrice() {
        navigator?.openPrice(listingCreationParams: listingCreationParams, postState: postOnboardingState.value)
    }
}
