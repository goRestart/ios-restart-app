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
        describe("PostProductState") {
            var sut: PostProductState!
            var featureFlags: MockFeatureFlags!
            
            beforeEach {
                featureFlags = MockFeatureFlags()
            }
            
            context("cars vertical disabled") {
                var oldSut: PostProductState!
                
                beforeEach {
                    featureFlags.carsVerticalEnabled = false
                    sut = PostProductState(featureFlags: featureFlags)
                    oldSut = sut
                }
                
                describe("init with feature flags") {
                    it("has step image selection") {
                        expect(sut.step) == PostProductStep.imageSelection
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
                            expect(sut.step) == PostProductStep.uploadingImage
                        }
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
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
                    
                    context("update pending to upload images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(pendingToUploadImages: []) // TODO: 🚔 Update w random UIImage
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to details selection") {
                            expect(sut.step) == PostProductStep.detailsSelection
                        }
                    }
                    
                    context("update uploaded images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(uploadedImages: [MockFile].makeMocks())
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to details selection") {
                            expect(sut.step) == PostProductStep.detailsSelection
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
                            expect(sut.step) == PostProductStep.errorUpload(message: "An error occurred while posting your product.")
                        }
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
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
                            expect(sut.step) == PostProductStep.uploadingImage
                        }
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("details selection") {
                    beforeEach {
                        sut = sut
                            .updatingStepToUploadingImages()
                            .updating(uploadedImages: [MockFile].makeMocks())
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    context("update price") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(price: ProductPrice.makeMock())
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to finished") {
                            expect(sut.step) == PostProductStep.finished
                        }
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
            }
            
            context("cars vertical enabled & cars category before picture") {
                var oldSut: PostProductState!
                
                beforeEach {
                    featureFlags.carsVerticalEnabled = true
                    featureFlags.carsCategoryAfterPicture = false
                    sut = PostProductState(featureFlags: featureFlags)
                    oldSut = sut
                }
                
                describe("init with feature flags") {
                    it("has step category selection") {
                        expect(sut.step) == PostProductStep.categorySelection
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
                
                context("category selection") {
                    describe("update category") {
                        beforeEach {
                            sut = sut.updating(category: .other)
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to image selection") {
                            expect(sut.step) == PostProductStep.imageSelection
                        }
                        
                        it("updates the category") {
                            expect(sut.category) == .other
                        }
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("image selection") {
                    beforeEach {
                        sut = sut.updating(category: .other)
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
                            expect(sut.step) == PostProductStep.uploadingImage
                        }
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("uploading images (w category car)") {
                    beforeEach {
                        sut = sut
                            .updating(category: .car)
                            .updatingStepToUploadingImages()
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    context("update pending to upload images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(pendingToUploadImages: []) // TODO: 🚔 Update w random UIImage
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to car details selection with price") {
                            expect(sut.step) == PostProductStep.carDetailsSelection(includePrice: true)
                        }
                    }
                    
                    context("update uploaded images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(uploadedImages: [MockFile].makeMocks())
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to car details selection with price") {
                            expect(sut.step) == PostProductStep.carDetailsSelection(includePrice: true)
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
                            expect(sut.step) == PostProductStep.errorUpload(message: "An error occurred while posting your product.")
                        }
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("uploading images (w category other)") {
                    beforeEach {
                        sut = sut
                            .updating(category: .other)
                            .updatingStepToUploadingImages()
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    context("update pending to upload images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(pendingToUploadImages: []) // TODO: 🚔 Update w random UIImage
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to details selection") {
                            expect(sut.step) == PostProductStep.detailsSelection
                        }
                    }
                    
                    context("update uploaded images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(uploadedImages: [MockFile].makeMocks())
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to details selection") {
                            expect(sut.step) == PostProductStep.detailsSelection
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
                            expect(sut.step) == PostProductStep.errorUpload(message: "An error occurred while posting your product.")
                        }
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("upload error") {
                    beforeEach {
                        sut = sut
                            .updating(category: .other)
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
                            expect(sut.step) == PostProductStep.uploadingImage
                        }
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("details selection") {
                    beforeEach {
                        sut = sut
                            .updating(category: .other)
                            .updatingStepToUploadingImages()
                            .updating(uploadedImages: [MockFile].makeMocks())
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    context("update price") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(price: ProductPrice.makeMock())
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to finished") {
                            expect(sut.step) == PostProductStep.finished
                        }
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("car details selection") {
                    beforeEach {
                        sut = sut
                            .updating(category: .car)
                            .updatingStepToUploadingImages()
                            .updating(uploadedImages: [MockFile].makeMocks())
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }

                    context("update price & car info") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(price: ProductPrice.makeMock(), carInfo: Void()) // TODO!
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to finished") {
                            expect(sut.step) == PostProductStep.finished
                        }
                    }
                }
            }
            
            context("cars vertical enabled & cars category after picture") {
                var oldSut: PostProductState!
                
                beforeEach {
                    featureFlags.carsVerticalEnabled = true
                    featureFlags.carsCategoryAfterPicture = true
                    sut = PostProductState(featureFlags: featureFlags)
                    oldSut = sut
                }
                
                describe("init with feature flags") {
                    it("has step image selection") {
                        expect(sut.step) == PostProductStep.imageSelection
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
                            expect(sut.step) == PostProductStep.uploadingImage
                        }
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
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
                    
                    context("update pending to upload images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(pendingToUploadImages: []) // TODO: 🚔 Update w random UIImage
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to car details selection with price") {
                            expect(sut.step) == PostProductStep.detailsSelection
                        }
                    }
                    
                    context("update uploaded images") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(uploadedImages: [MockFile].makeMocks())
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to car details selection with price") {
                            expect(sut.step) == PostProductStep.detailsSelection
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
                            expect(sut.step) == PostProductStep.errorUpload(message: "An error occurred while posting your product.")
                        }
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
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
                            expect(sut.step) == PostProductStep.uploadingImage
                        }
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("details selection") {
                    beforeEach {
                        sut = sut
                            .updatingStepToUploadingImages()
                            .updating(uploadedImages: [MockFile].makeMocks())
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    context("update price") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(price: ProductPrice.makeMock())
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to category selection") {
                            expect(sut.step) == PostProductStep.categorySelection
                        }
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("category selection") {
                    beforeEach {
                        sut = sut
                            .updatingStepToUploadingImages()
                            .updating(uploadedImages: [MockFile].makeMocks())
                            .updating(price: ProductPrice.makeMock())
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
                            expect(sut.step) == PostProductStep.finished
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
                            expect(sut.step) == PostProductStep.carDetailsSelection(includePrice: false)
                        }
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    it("returns the same state when updating car info") {
                        expect(sut.updating(carInfo: Void())) === sut   // TODO: 🚔 Update w car info
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
                
                context("car details selection") {
                    beforeEach {
                        sut = sut
                            .updatingStepToUploadingImages()
                            .updating(uploadedImages: [MockFile].makeMocks())
                            .updating(price: ProductPrice.makeMock())
                            .updating(category: .car)
                    }
                    
                    it("returns the same state when updating category") {
                        expect(sut.updating(category: .other)) === sut
                    }
                    
                    it("returns the same state when updating step to uploading images") {
                        expect(sut.updatingStepToUploadingImages()) === sut
                    }
                    
                    it("returns the same state when updating pending to upload images") {
                        expect(sut.updating(pendingToUploadImages: [])) === sut  // TODO: 🚔 Update w random UIImage
                    }
                    
                    it("returns the same state when updating uploaded images") {
                        expect(sut.updating(uploadedImages: [MockFile].makeMocks())) === sut
                    }
                    
                    it("returns the same state when updating upload error") {
                        expect(sut.updating(uploadError: .notFound)) === sut
                    }
                    
                    it("returns the same state when updating price") {
                        expect(sut.updating(price: ProductPrice.makeMock())) === sut
                    }
                    
                    context("update car info") {
                        beforeEach {
                            oldSut = sut
                            sut = sut.updating(carInfo: Void()) // TODO: 🚔 Update w car info
                        }
                        
                        it("returns a new state") {
                            expect(sut) !== oldSut
                        }
                        
                        it("updates the step to finished") {
                            expect(sut.step) == PostProductStep.finished
                        }
                    }
                    
                    it("returns the same state when updating price & car info") {
                        expect(sut.updating(price: ProductPrice.makeMock(), carInfo: Void())) === sut
                    }
                }
            }
        }
    }
}
