//
//  PostProductStateSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
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
            
            describe("initial state") {
                context("cars vertical disabled & cars category after picture false") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = false
                        featureFlags.carsCategoryAfterPicture = false
                        sut = PostProductState.initialState(featureFlags: featureFlags)
                    }
                    
                    it("is image selection") {
                        expect(sut) == .imageSelection
                    }
                }
                
                context("cars vertical disabled & cars category after picture true") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = false
                        featureFlags.carsCategoryAfterPicture = true
                        sut = PostProductState.initialState(featureFlags: featureFlags)
                    }
                    
                    it("is image selection") {
                        expect(sut) == .imageSelection
                    }
                }
                
                context("cars vertical enabled & cars category after picture false") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = true
                        featureFlags.carsCategoryAfterPicture = false
                        sut = PostProductState.initialState(featureFlags: featureFlags)
                    }
                    
                    it("is category selection") {
                        expect(sut) == .categorySelection
                    }
                }
                
                context("cars vertical enabled & cars category after picture true") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = true
                        featureFlags.carsCategoryAfterPicture = true
                        sut = PostProductState.initialState(featureFlags: featureFlags)
                    }
                    
                    it("is image selection") {
                        expect(sut) == .imageSelection
                    }
                }
            }
            
            describe("next state") {
                context("cars vertical disabled & cars category after picture false") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = false
                        featureFlags.carsCategoryAfterPicture = false
                    }
                    
                    describe("image selection") {
                        beforeEach {
                            sut = .imageSelection
                        }
                        
                        it("is details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .detailsSelection
                        }
                    }
                    
                    describe("uploading image") {
                        beforeEach {
                            sut = .uploadingImage
                        }
                        
                        it("is details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .detailsSelection
                        }
                    }
                    
                    describe("error upload") {
                        beforeEach {
                            sut = .errorUpload(message: "message")
                        }
                        
                        it("is details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .detailsSelection
                        }
                    }
                    
                    describe("details selection") {
                        beforeEach {
                            sut = .detailsSelection
                        }
                        
                        it("has no next state") {
                            expect(sut.nextState(featureFlags: featureFlags)).to(beNil())
                        }
                    }
                    
                    describe("category selection") {
                        beforeEach {
                            sut = .categorySelection
                        }
                        
                        it("has no next state") {
                            expect(sut.nextState(featureFlags: featureFlags)).to(beNil())
                        }
                    }
                    
                    describe("car details selection") {
                        beforeEach {
                            sut = .carDetailsSelection(includePrice: true)
                        }
                        
                        it("has no next state") {
                            expect(sut.nextState(featureFlags: featureFlags)).to(beNil())
                        }
                    }
                }
                
                context("cars vertical disabled & cars category after picture true") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = false
                        featureFlags.carsCategoryAfterPicture = true
                    }
                    
                    describe("image selection") {
                        beforeEach {
                            sut = .imageSelection
                        }
                        
                        it("is details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .detailsSelection
                        }
                    }
                    
                    describe("uploading image") {
                        beforeEach {
                            sut = .uploadingImage
                        }
                        
                        it("is details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .detailsSelection
                        }
                    }
                    
                    describe("error upload") {
                        beforeEach {
                            sut = .errorUpload(message: "message")
                        }
                        
                        it("is details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .detailsSelection
                        }
                    }
                    
                    describe("details selection") {
                        beforeEach {
                            sut = .detailsSelection
                        }
                        
                        it("has no next state") {
                            expect(sut.nextState(featureFlags: featureFlags)).to(beNil())
                        }
                    }
                    
                    describe("category selection") {
                        beforeEach {
                            sut = .categorySelection
                        }
                        
                        it("has no next state") {
                            expect(sut.nextState(featureFlags: featureFlags)).to(beNil())
                        }
                    }
                    
                    describe("car details selection") {
                        beforeEach {
                            sut = .carDetailsSelection(includePrice: true)
                        }
                        
                        it("has no next state") {
                            expect(sut.nextState(featureFlags: featureFlags)).to(beNil())
                        }
                    }
                }
                
                context("cars vertical enabled & cars category after picture false") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = true
                        featureFlags.carsCategoryAfterPicture = false
                    }
                    
                    describe("image selection") {
                        beforeEach {
                            sut = .imageSelection
                        }
                        
                        it("is car details selection with price") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .carDetailsSelection(includePrice: true)
                        }
                    }
                    
                    describe("uploading image") {
                        beforeEach {
                            sut = .uploadingImage
                        }
                        
                        it("is car details selection with price") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .carDetailsSelection(includePrice: true)
                        }
                    }
                    
                    describe("error upload") {
                        beforeEach {
                            sut = .errorUpload(message: "message")
                        }
                        
                        it("is car details selection with price") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .carDetailsSelection(includePrice: true)
                        }
                    }
                    
                    describe("details selection") {
                        beforeEach {
                            sut = .detailsSelection
                        }
                        
                        it("has no next state") {
                            expect(sut.nextState(featureFlags: featureFlags)).to(beNil())
                        }
                    }
                    
                    describe("category selection") {
                        beforeEach {
                            sut = .categorySelection
                        }
                        
                        it("is image selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .imageSelection
                        }
                    }
                    
                    describe("car details selection") {
                        beforeEach {
                            sut = .carDetailsSelection(includePrice: true)
                        }
                        
                        it("has no next state") {
                            expect(sut.nextState(featureFlags: featureFlags)).to(beNil())
                        }
                    }
                }
                
                context("cars vertical enabled & cars category after picture true") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = true
                        featureFlags.carsCategoryAfterPicture = true
                    }
                    
                    describe("image selection") {
                        beforeEach {
                            sut = .imageSelection
                        }
                        
                        it("is details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .detailsSelection
                        }
                    }
                    
                    describe("uploading image") {
                        beforeEach {
                            sut = .uploadingImage
                        }
                        
                        it("is details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .detailsSelection
                        }
                    }
                    
                    describe("error upload") {
                        beforeEach {
                            sut = .errorUpload(message: "message")
                        }
                        
                        it("is details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .detailsSelection
                        }
                    }
                    
                    describe("details selection") {
                        beforeEach {
                            sut = .detailsSelection
                        }

                        it("is category selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .categorySelection
                        }
                    }
                    
                    describe("category selection") {
                        beforeEach {
                            sut = .categorySelection
                        }
                        
                        it("is car details selection") {
                            expect(sut.nextState(featureFlags: featureFlags)) == .carDetailsSelection(includePrice: false)
                        }
                    }
                    
                    describe("car details selection") {
                        beforeEach {
                            sut = .carDetailsSelection(includePrice: true)
                        }
                        
                        it("has no next state") {
                            expect(sut.nextState(featureFlags: featureFlags)).to(beNil())
                        }
                    }
                }
            }
            
            describe("is last state") {
                context("cars vertical disabled") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = false
                    }
                    
                    describe("image selection") {
                        beforeEach {
                            sut = .imageSelection
                        }
                        
                        it("is not last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == false
                        }
                    }
                    
                    describe("uploading image") {
                        beforeEach {
                            sut = .uploadingImage
                        }
                        
                        it("is not last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == false
                        }
                    }
                    
                    describe("error upload") {
                        beforeEach {
                            sut = .errorUpload(message: "message")
                        }
                        
                        it("is not last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == false
                        }
                    }
                    
                    describe("details selection") {
                        beforeEach {
                            sut = .detailsSelection
                        }
                        
                        it("is last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == true
                        }
                    }
                    
                    describe("category selection") {
                        beforeEach {
                            sut = .categorySelection
                        }
                        
                        it("is not last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == false
                        }
                    }
                    
                    describe("car details selection") {
                        beforeEach {
                            sut = .carDetailsSelection(includePrice: true)
                        }
                        
                        it("is last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == true
                        }
                    }
                }
                
                context("cars vertical enabled") {
                    beforeEach {
                        featureFlags.carsVerticalEnabled = true
                    }
                    
                    describe("image selection") {
                        beforeEach {
                            sut = .imageSelection
                        }
                        
                        it("is not last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == false
                        }
                    }
                    
                    describe("uploading image") {
                        beforeEach {
                            sut = .uploadingImage
                        }
                        
                        it("is not last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == false
                        }
                    }
                    
                    describe("error upload") {
                        beforeEach {
                            sut = .errorUpload(message: "message")
                        }
                        
                        it("is not last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == false
                        }
                    }
                    
                    describe("details selection") {
                        beforeEach {
                            sut = .detailsSelection
                        }
                        
                        it("is not last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == false
                        }
                    }
                    
                    describe("category selection") {
                        beforeEach {
                            sut = .categorySelection
                        }
                        
                        it("is not last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == false
                        }
                    }
                    
                    describe("car details selection") {
                        beforeEach {
                            sut = .carDetailsSelection(includePrice: true)
                        }
                        
                        it("is last state") {
                            expect(sut.isLastState(featureFlags: featureFlags)) == true
                        }
                    }
                }
            }
        }
    }
}
