//
//  ProductsManagerSpec.swift
//  LGCoreKit
//
//  Created by AHL on 2/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Bolts
import CoreLocation
import Quick
import LGCoreKit
import Nimble

class EdibleSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("eventually with valid session") { (sharedExampleContext: SharedExampleContext) in
            var sut: ProductsManager!
            
            var sessionManager: MockSessionManager!
            var productsService: MockProductsService!
            
            var receivedProducts: NSArray?
            var receivedError: NSError?
            
            let completion = { (task: BFTask!) -> AnyObject! in
                receivedProducts = task.result as? NSArray
                receivedError = task.error
                return nil
            }
            
            beforeEach {
                sessionManager = sharedExampleContext()["sessionManager"] as! MockSessionManager
                productsService = MockProductsService()
                
                sut = ProductsManager(sessionManager: sessionManager, productsService: productsService)
                
                receivedProducts = nil
                receivedError = nil
            }
            
            describe("first page retrieval") {
                let params = RetrieveProductsParams(coordinates: LGLocationCoordinates2D(latitude: 0, longitude: 0), accessToken: "")!
                
                describe("a last page response") {
                    let products = LGPartialProduct.mocks(5)
                    
                    beforeEach {
                        productsService.products = products
                        productsService.lastPage = true
                        sut.retrieveProductsWithParams(params)?.continueWithBlock(completion)
                    }
                    
                    it("is loading and eventually not loading") {
                        expect(sut.isLoading).to(beTrue())
                        expect(sut.isLoading).toEventually(beFalse())
                    }
                    it("updates its products with the received ones") {
                        expect(sut.products).toEventually(equal(products))
                    }
                    it("returns the products as result when completing the task") {
                        expect(receivedProducts).toEventually(equal(products))
                    }
                    it("indicates that is the last page") {
                        expect(sut.lastPage).toEventually(beTrue())
                    }
                    it("update its current params") {
                        expect(sut.currentParams).toEventually(equal(params))
                    }
                }
                
                describe("a page response with more pages") {
                    let products = LGPartialProduct.mocks(20)
                    
                    beforeEach {
                        productsService.products = products
                        productsService.lastPage = false
                        sut.retrieveProductsWithParams(params)?.continueWithBlock(completion)
                    }
                    
                    it("is loading and eventually not loading") {
                        expect(sut.isLoading).to(beTrue())
                        expect(sut.isLoading).toEventually(beFalse())
                    }
                    it("updates its products with the received ones") {
                        expect(sut.products).toEventually(equal(products))
                    }
                    it("returns the products as result when completing the task") {
                        expect(receivedProducts).toEventually(equal(products))
                    }
                    it("indicates that is not the last page") {
                        expect(sut.lastPage).toEventually(beFalse())
                    }
                    it("update its current params") {
                        expect(sut.currentParams).toEventually(equal(params))
                    }
                }
                
                describe("error response") {
                    let error = NSError(code: LGErrorCode.UnexpectedServerResponse)
                    
                    beforeEach {
                        productsService.error = error
                        sut.retrieveProductsWithParams(params)?.continueWithBlock(completion)
                    }
                    
                    it("is loading and eventually not loading") {
                        expect(sut.isLoading).to(beTrue())
                        expect(sut.isLoading).toEventually(beFalse())
                    }
                    it("returns the error as error when completing the task") {
                        expect(receivedError).toEventually(equal(error))
                    }
                    it("indicates that is the last page") {
                        expect(sut.lastPage).toEventually(beTrue())
                    }
                    it("does not update its current params") {
                        expect(sut.currentParams).toEventually(beNil())
                    }
                }
            }
            
            describe("next page retrieval without requesting first page before") {
                
                it("should do nothing") {
                    let task = sut.retrieveProductsNextPage()
                    expect(task).to(beNil())
                    expect(sut.isLoading).to(beFalse())
                }
            }
            
            describe("next page retrieval after a first page one") {
                let params = RetrieveProductsParams(coordinates: LGLocationCoordinates2D(latitude: 0, longitude: 0), accessToken: "")!
                
                
                beforeEach {
                    productsService.products = LGPartialProduct.mocks(20)
                    productsService.lastPage = false
                    
                    sut.retrieveProductsWithParams(params)?.continueWithBlock(completion)
                    expect(sut.isLoading).toEventually(beFalse())
                }
                
                describe("a last page response") {
                    let newProducts = LGPartialProduct.mocks(5)
                    
                    beforeEach {
                        productsService.products = newProducts
                        productsService.lastPage = true
                        sut.retrieveProductsNextPage()?.continueWithBlock(completion)
                    }
                    
                    it("is loading and eventually not loading") {
                        expect(sut.isLoading).to(beTrue())
                        expect(sut.isLoading).toEventually(beFalse())
                    }
                    it("updates its products with the received ones") {
                        expect(sut.products.count).toEventually(equal(25))
                    }
                    it("returns the products as result when completing the task") {
                        expect(receivedProducts).toEventually(equal(newProducts))
                    }
                    it("indicates that is the last page") {
                        expect(sut.lastPage).toEventually(beTrue())
                    }
                    it("updates its current params increasing the offset") {
                        expect(sut.currentParams!.offset).toEventually(equal(20))
                    }
                }
                
                describe("a page response with more pages") {
                    let newProducts = LGPartialProduct.mocks(20)
                    
                    beforeEach {
                        productsService.products = newProducts
                        productsService.lastPage = true
                        sut.retrieveProductsNextPage()?.continueWithBlock(completion)
                    }
                    
                    it("is loading and eventually not loading") {
                        expect(sut.isLoading).to(beTrue())
                        expect(sut.isLoading).toEventually(beFalse())
                    }
                    it("updates its products with the received ones") {
                        expect(sut.products.count).toEventually(equal(40))
                    }
                    it("returns the products as result when completing the task") {
                        expect(receivedProducts).toEventually(equal(newProducts))
                    }
                    it("indicates that is not the last page") {
                        expect(sut.lastPage).toEventually(beTrue())
                    }
                    it("updates its current params increasing the offset") {
                        expect(sut.currentParams!.offset).toEventually(equal(20))
                    }
                }
                
                describe("error response") {
                    let error = NSError(code: LGErrorCode.UnexpectedServerResponse)
                    
                    beforeEach {
                        productsService.error = error
                        sut.retrieveProductsNextPage()?.continueWithBlock(completion)
                    }
                    
                    it("is loading and eventually not loading") {
                        expect(sut.isLoading).to(beTrue())
                        expect(sut.isLoading).toEventually(beFalse())
                    }
                    it("returns the error as error when completing the task") {
                        expect(receivedError).toEventually(equal(error))
                    }
                    it("indicates that is not the last page") {
                        expect(sut.lastPage).toEventually(beFalse())
                    }
                    it("does not update its current params increasing the offset") {
                        expect(sut.currentParams!.offset).toEventually(beNil())
                    }
                }
            }
        }
        
        sharedExamples("eventually with expired session") { (sharedExampleContext: SharedExampleContext) in
            var sut: ProductsManager!
            
            var sessionManager: MockSessionManager!
            var productsService: MockProductsService!
            
            var receivedProducts: NSArray?
            var receivedError: NSError?
            
            let completion = { (task: BFTask!) -> AnyObject! in
                receivedProducts = task.result as? NSArray
                receivedError = task.error
                return nil
            }
            
            beforeEach {
                sessionManager = sharedExampleContext()["sessionManager"] as! MockSessionManager
                productsService = MockProductsService()
                
                sut = ProductsManager(sessionManager: sessionManager, productsService: productsService)
                
                receivedProducts = nil
                receivedError = nil
            }
            
            describe("first page retrieval") {
                let params = RetrieveProductsParams(coordinates: LGLocationCoordinates2D(latitude: 0, longitude: 0), accessToken: "")!
                
                beforeEach {
                    sut.retrieveProductsWithParams(params)?.continueWithBlock(completion)
                }
                
                it("is loading and eventually not loading") {
                    expect(sut.isLoading).to(beTrue())
                    expect(sut.isLoading).toEventually(beFalse())
                }
                
                it("does not update its products") {
                    expect(sut.products).toEventually(beEmpty())
                }
                
                it("receives an error") {
                    expect(sut.products).toEventuallyNot(beNil())
                }
            }
            
            describe("next page retrieval, when first succeeded") {
                let params = RetrieveProductsParams(coordinates: LGLocationCoordinates2D(latitude: 0, longitude: 0), accessToken: "")!

                beforeEach {
                    let expiredToken = LGSessionToken(accessToken: "", expirationDate: NSDate(timeIntervalSinceNow: -3600))
                    let validToken = LGSessionToken(accessToken: "", expirationDate: NSDate(timeIntervalSinceNow: 3600))
                    sessionManager.sessionToken = validToken
                    
                    let products = LGPartialProduct.mocks(20)
                    productsService.products = products
                    productsService.lastPage = false
                    sut.retrieveProductsWithParams(params)
                    expect(sut.isLoading).toEventually(beFalse())
                    
                    sessionManager.sessionToken = expiredToken
                    sut.retrieveProductsNextPage()
                    println()
                }
                
                it("is loading and eventually not loading") {
                    expect(sut.isLoading).to(beTrue())
                    expect(sut.isLoading).toEventually(beFalse())
                }
                
                it("does not update its products") {
                    expect(sut.isLoading).toEventually(beFalse())
                    expect(sut.products.count).toEventually(equal(20))
                }
                
                it("receives an error") {
                    expect(sut.products).toEventuallyNot(beNil())
                }
            }
        }
    }
}

class ProductsManagerSpec: QuickSpec {
    
    override func spec() {
        var sut: ProductsManager!
        var sessionManager: MockSessionManager!
        
        beforeEach {
            sessionManager = MockSessionManager()
        }
        
        afterEach {
            sessionManager.deleteStoredData()
        }

        describe("initial state") {
            beforeEach {
                let productsService = MockProductsService()
                sut = ProductsManager(sessionManager: sessionManager, productsService: productsService)
            }
            
            it("has no current params") {
                expect(sut.currentParams).to(beNil())
            }
            it("has no products") {
                expect(sut.products).to(beEmpty())
            }
            it("is the last page") {
                expect(sut.lastPage).to(beTrue())
            }
            it("is not loading") {
                expect(sut.isLoading).to(beFalse())
            }
        }
        
        context("valid session") {
            beforeEach {
                let validToken = LGSessionToken(accessToken: "", expirationDate: NSDate(timeIntervalSinceNow: 3600))
                sessionManager.sessionToken = validToken
            }
            
            itBehavesLike("eventually with valid session") { [ "sessionManager": sessionManager ] }
        }
        
        context("expired session, retrieve token successful") {
            
            beforeEach {
                let expiredToken = LGSessionToken(accessToken: "", expirationDate: NSDate(timeIntervalSinceNow: -3600))
                let validToken = LGSessionToken(accessToken: "", expirationDate: NSDate(timeIntervalSinceNow: 3600))
                sessionManager.sessionToken = expiredToken
                sessionManager.sessionService.sessionToken = validToken
            }
            
            itBehavesLike("eventually with valid session") { [ "sessionManager": sessionManager ] }
        }
        
        context("expired session, retrieve token failure") {
            
            beforeEach {
                sessionManager.sessionService.error = NSError(code: LGErrorCode.UnexpectedServerResponse)
            }
            
            itBehavesLike("eventually with expired session") { [ "sessionManager": sessionManager ] }
        }
    }
}

