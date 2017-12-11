//
//  PostingQueuedRequestsLoadingViewModelSpec.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 05/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift
import RxTest


class PostingQueuedRequestsLoadingViewModelSpec: BaseViewModelSpec {
    
    override func spec() {
        describe("PostingQueuedRequestsLoadingViewModelSpec") {
            var sut: PostingQueuedRequestsLoadingViewModel!
            //var sessionManager: MockSessionManager!
            //var featureFlags: MockFeatureFlags!
            //var tracker: MockTracker!
            var fileRepository: MockFileRepository!
            var listingRepository: MockListingRepository!
            var images: [UIImage]!
            var postListingState: PostListingState!
            var isLoadingObserver: TestableObserver<Bool>!
            var gotListingCreateResponseObserver: TestableObserver<Bool>!
            var disposeBag: DisposeBag!
            let productPostGenericError = (RepositoryError.internalError,  RepositoryError.unauthorized, RepositoryError.notFound,
                                           RepositoryError.forbidden, RepositoryError.tooManyRequests, RepositoryError.userNotVerified,
                                           RepositoryError.serverError, RepositoryError.wsChatError)
            

            beforeEach {
                //sessionManager = MockSessionManager()
                //tracker = MockTracker()
                fileRepository = MockFileRepository()
                listingRepository = MockListingRepository()
                images = [UIImage].makeRandom()
                postListingState = PostListingState(postCategory: .unassigned)
                let listingCreationParams = ListingCreationParams.make(title: String.makeRandom(),
                                                                       description: String.makeRandom(),
                                                                       currency: Currency.makeMock(),
                                                                       location: LGLocationCoordinates2D.makeMock(),
                                                                       postalAddress: PostalAddress.makeMock(),
                                                                       postListingState: postListingState)
                sut = PostingQueuedRequestsLoadingViewModel(images: images,
                                                            listingCreationParams: listingCreationParams,
                                                            postState: postListingState,
                                                            listingRepository: listingRepository,
                                                            fileRepository: fileRepository)
                
                let scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                
                isLoadingObserver = scheduler.createObserver(Bool.self)
                gotListingCreateResponseObserver = scheduler.createObserver(Bool.self)
                disposeBag = DisposeBag()
                
                sut.isLoading.asObservable().bindTo(isLoadingObserver).addDisposableTo(disposeBag)
                sut.gotListingCreateResponse.asObservable().bindTo(gotListingCreateResponseObserver).addDisposableTo(disposeBag)
            }
                
            afterEach {
                sut.isLoading.value = false
            }
            
            describe("create listing") {
                
                context("images upload success") {
                    
                    var files: [MockFile]!
                    
                    beforeEach {
                        files = [MockFile].makeMocks()
                        fileRepository.uploadFilesResult = FilesResult(value: files)
                    }
                    
                    context("listing creation success") {
                        beforeEach {
                            let newProduct = MockProduct.makeMock()
                            listingRepository.listingResult = ListingResult(value: .product(newProduct))
                            sut.createListingAfterUploadingImages()
                            expect(sut.gotListingCreateResponse.value).toEventually(beTrue())
                        }
                        
                        it("isLoading emits: false, true, false") {
                            expect(isLoadingObserver.eventValues).toEventually(equal([false, true, false]))
                        }
                        
                        it("step is set to listingCreationSuccess case") {
                            let step = sut.postOnboardingState.value.postOnboardingStep
                            expect(step).toEventually(equal(PostOnboardingListingStep.listingCreationSuccess))
                        }
                    }
                    
                    context("images upload fail") {
                        beforeEach {
                            listingRepository.listingResult = ListingResult(error: productPostGenericError)
                            sut.createListingAfterUploadingImages()
                            expect(sut.gotListingCreateResponse.value).toEventually(beTrue())
                        }
                        
                        it("isLoading emits: false, true, false") {
                            expect(isLoadingObserver.eventValues).toEventually(equal([false, true, false]))
                        }
                        
                        it("step is set to listingCreationSuccess case") {
                            let step = sut.postOnboardingState.value.postOnboardingStep
                            expect(step).to(equal(PostOnboardingListingStep.listingCreationError(message: LGLocalizedString.productPostGenericError)))
                        }
                    }
                }
            }
            
        }
    }
}

