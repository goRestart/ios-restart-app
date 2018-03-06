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
    private let source: EventParameterPictureSource
    let postListingState: Variable<PostListingState>
    let isLoading = Variable<Bool>(false)
    let gotListingCreateResponse = Variable<Bool>(false)
    fileprivate var listingResult: ListingResult?
    
    weak var navigator: PostingHastenedCreateProductNavigator?
    private let disposeBag = DisposeBag()
    
    var finishRequest = Variable<Bool?>(false)
    
    
    // MARK: - Lifecycle
    
    convenience init(images: [UIImage], listingCreationParams: ListingCreationParams,
                     postState: PostListingState, source: EventParameterPictureSource) {
        self.init(listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  images: images,
                  listingCreationParams: listingCreationParams,
                  postState: postState,
                  source: source)
    }
    
    convenience init(images: [UIImage], listingCreationParams: ListingCreationParams, postState: PostListingState,
                     source: EventParameterPictureSource, listingRepository: ListingRepository,
                     fileRepository: FileRepository) {
        self.init(listingRepository: listingRepository,
                  fileRepository: fileRepository,
                  images: images,
                  listingCreationParams: listingCreationParams,
                  postState: postState,
                  source: source)
    }
    
    init(listingRepository: ListingRepository,
         fileRepository: FileRepository,
         images: [UIImage],
         listingCreationParams: ListingCreationParams,
         postState: PostListingState,
         source: EventParameterPictureSource) {
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.images = images
        self.listingCreationParams = listingCreationParams
        self.source = source
        self.postListingState = Variable<PostListingState>(postState)
        super.init()
    }
    
    
    // MARK: - Navigation
    
    func openPrice(listing: Listing) {
        navigator?.openPrice(listing: listing, postState: postListingState.value)
    }
}
