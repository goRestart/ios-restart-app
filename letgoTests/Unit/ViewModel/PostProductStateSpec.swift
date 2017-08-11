//
//  PostProductStateSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble


class PostProductStateSpec: BaseViewModelSpec {
   
    override func spec() {
        describe("PostListingState") {
            var sut: PostListingState!
            var featureFlags: MockFeatureFlags!
            
            beforeEach {
                featureFlags = MockFeatureFlags()
            }
            
            context("cars category after picture") {
                var oldSut: PostListingState!
                
                beforeEach {
                    sut = PostListingState(featureFlags: featureFlags)
                    oldSut = sut
                }
                
                describe("init with feature flags") {
                    it("has step image selection") {
                        expect(sut.step) == PostListingStep.imageSelection
                    }
                    it("has no category") {
                        expect(sut.category).to(beNil())
                    }
                    it("has no pending to upload images") {
                        expect(sut.category).to(beNil())
                    }
                    it("has no result of image upload") {
                        expect(sut.category).to(beNil())
                    }
                    it("has no price") {
                        expect(sut.price).to(beNil())
                    }
                    it("has no car info") {
                        expect(sut.carInfo).to(beNil())
                    }
                }
                
                context("image selection") {
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    context("update step to uploading images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updatingStepToUploadingImages()
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to uploading images") {
                            expect(sut.step) == PostListingStep.uploadingImage
                        }
                    }
                    
                    context("update pending to upload images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(pendingToUploadImages: [UIImage].makeRandom())
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to car details selection with price") {
                            expect(sut.step) == PostListingStep.detailsSelection
                        }
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ListingPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: CarAttributes.emptyCarAttributes())) === sut    
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ListingPrice.makeMock(), carInfo: CarAttributes.emptyCarAttributes())) === sut
                    }
                }
                
                context("uploading images") {
                    beforeEach {
                        sut = sut.updatingStepToUploadingImages()
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [UIImage].makeRandom())) === sut
                    }
                    
                    context("update uploaded images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())
                                    .updatingAfterUploadingSuccess()
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to car details selection with price") {
                            expect(sut.step) == PostListingStep.detailsSelection
                        }
                    }
                    
                    context("update upload error") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(uploadError: .notFound)
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to details selection") {
                            expect(sut.step) == PostListingStep.errorUpload(message: "An error occurred while posting your product.")
                        }
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ListingPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: CarAttributes.emptyCarAttributes())) === sut    
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ListingPrice.makeMock(), carInfo: CarAttributes.emptyCarAttributes())) === sut
                    }
                }
                
                context("upload error") {
                    beforeEach {
                        sut = sut
                            .updatingStepToUploadingImages()
                            .updating(uploadError: .notFound)
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    context("update step to uploading images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updatingStepToUploadingImages()
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to uploading images") {
                            expect(sut.step) == PostListingStep.uploadingImage
                        }
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [UIImage].makeRandom())) === sut
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ListingPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: CarAttributes.emptyCarAttributes())) === sut    
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ListingPrice.makeMock(), carInfo: CarAttributes.emptyCarAttributes())) === sut
                    }
                }
                
                context("details selection") {
                    beforeEach {
                        sut = sut
                            .updatingStepToUploadingImages()
                            .updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [UIImage].makeRandom())) === sut
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    context("update price") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updatingAfterUploadingSuccess()
                            sut = sut.updating(price: ListingPrice.makeMock())
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to category selection") {
                            expect(sut.step) == PostListingStep.categorySelection
                        }
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: CarAttributes.emptyCarAttributes())) === sut    
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ListingPrice.makeMock(), carInfo: CarAttributes.emptyCarAttributes())) === sut
                    }
                }
                
                context("category selection") {
                    beforeEach {
                        sut = sut.updatingStepToUploadingImages()
                        sut = sut.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())
                        sut = sut.updatingAfterUploadingSuccess()
                        sut = sut.updating(price: ListingPrice.makeMock())
                    }
                    
                    context("update category to other") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(category: .other)
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to finished") {
                            expect(sut.step) == PostListingStep.finished
                        }
                    }
                    
                    context("update category to cars") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(category: .car)
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to car details w/o price") {
                            expect(sut.step) == PostListingStep.carDetailsSelection
                        }
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [UIImage].makeRandom())) === sut
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ListingPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: CarAttributes.emptyCarAttributes())) === sut    
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ListingPrice.makeMock(), carInfo: CarAttributes.emptyCarAttributes())) === sut
                    }
                }
                
                context("car details selection") {
                    beforeEach {
                        sut = sut
                            .updatingStepToUploadingImages()
                            .updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())
                            .updatingAfterUploadingSuccess()
                            .updating(price: ListingPrice.makeMock())
                            .updating(category: .car)
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [UIImage].makeRandom())) === sut
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ListingPrice.makeMock())) === sut
                    }
                    
                    context("update car info") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(carInfo: CarAttributes.emptyCarAttributes())  
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to finished") {
                            expect(sut.step) == PostListingStep.finished
                        }
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ListingPrice.makeMock(), carInfo: CarAttributes.emptyCarAttributes())) === sut
                    }
                }
            }
        }
    }
}
