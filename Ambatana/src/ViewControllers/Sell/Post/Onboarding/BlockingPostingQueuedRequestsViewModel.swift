//
//  PostingQueuedRequestsLoadingViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 04/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class BlockingPostingQueuedRequestsViewModel: BaseViewModel {
    
    enum QueueState {
        case uploadingImages            // UI: "Automatically generating title..."
        case postingListing             // UI: "Automatically categorizing listing..."
        case postingListingExtraTime    // UI: "Posting listing..."
        case listingPosted
        case error
        
        var message: String {
            switch self {
            case .uploadingImages:
                return "Automatically generating title"
            case .postingListing:
                return "Automatically categorizing listing"
            case .postingListingExtraTime:
                return "Posting listing"
            case .listingPosted:
                return "Listing posted!"
            case .error:
                return "Error"
            }
        }
    }

    private static let stateDelay: TimeInterval = 1.5
    
    private let listingRepository: ListingRepository
    private let fileRepository: FileRepository
    private let images: [UIImage]
    private var listingCreationParams: ListingCreationParams
    private let source: EventParameterPictureSource
    
    var queueState = Variable<QueueState?>(nil)
    var uploadImagesResult = Variable<FilesResult?>(nil)
    var createListingResult = Variable<ListingResult?>(nil)
    var createListingExtraTimeTriggered = Variable<Bool>(false)
    var listingPostedTriggered = Variable<Bool>(false)
    
    private var listingCreated: Listing?
    
    let postListingState: Variable<PostListingState>
    let isLoading = Variable<Bool>(false)
    let gotListingCreateResponse = Variable<Bool>(false)
    fileprivate var listingResult: ListingResult?
    
    weak var navigator: BlockingPostingNavigator?
    private let disposeBag = DisposeBag()
    
    
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
        setupRx()
    }
    
    private func setupRx() {
        queueState.asObservable().bind { [weak self] state in
            guard let strongSelf = self else { return }
            guard let state = state else { return }
            switch state {
            case .uploadingImages:
                strongSelf.uploadImages()
            case .postingListing:
                strongSelf.createListing()
            case .postingListingExtraTime:
                strongSelf.createListingExtraTimeTriggered.value = true
            case .listingPosted:
                strongSelf.listingPostedTriggered.value = true
            case .error:
                break
            }
            }.disposed(by: disposeBag)
        
        uploadImagesResult.asObservable()
            .filter{ r -> Bool in r != nil }
            .delay(BlockingPostingQueuedRequestsViewModel.stateDelay, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] result in
                guard let strongSelf = self else { return }
                guard let result = result else { return }
                if let images = result.value {
                    strongSelf.listingCreationParams = strongSelf.listingCreationParams.updating(images: images)
                    strongSelf.queueState.value = .postingListing
                } else {
                    strongSelf.queueState.value = .error
                }
        }.disposed(by: disposeBag)

        createListingResult.asObservable()
            .filter{r -> Bool in r != nil}
            .delay(BlockingPostingQueuedRequestsViewModel.stateDelay, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] result in
                guard let strongSelf = self else { return }
                guard let result = result else { return }
                if let listing = result.value {
                    strongSelf.listingCreated = listing
                    strongSelf.queueState.value = .postingListingExtraTime
                } else {
                    strongSelf.queueState.value = .error
                }
            }.disposed(by: disposeBag)
        
        createListingExtraTimeTriggered.asObservable()
            .filter{ $0 }
            .delay(BlockingPostingQueuedRequestsViewModel.stateDelay, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.queueState.value = .listingPosted
            }.disposed(by: disposeBag)
    
        listingPostedTriggered.asObservable()
            .filter{ $0 }
            .delay(BlockingPostingQueuedRequestsViewModel.stateDelay, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] result in
                guard let strongSelf = self else { return }
                if let listing = strongSelf.listingCreated {
                    strongSelf.openPrice(listing: listing)
                } else {
                    strongSelf.queueState.value = .error
                }
            }.disposed(by: disposeBag)
    }
    

    // MARK: - Requests
    
    func uploadImages() {
        fileRepository.upload(images, progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.uploadImagesResult.value = result
        }

    }
    
    private func createListing() {
        listingRepository.create(listingParams: listingCreationParams) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.createListingResult.value = result
        }
    }
    
    
    // MARK: - Navigation
    
    func openPrice(listing: Listing) {
        navigator?.openPrice(listing: listing, postState: postListingState.value)
    }
}
