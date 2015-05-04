//
//  LGProductsServiceSpec.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Quick
import LGCoreKit
import Mockingjay
import Nimble
import SwiftyJSON

class LGProductsServiceSpec: QuickSpec {
    
    override func spec() {
        var sut: ProductsService!
        
        var receivedProducts: NSArray?
        var receivedError: NSError?
        var receivedIsLastPage: Bool?
        
        let completion = { (products: NSArray?, isLastPage: Bool?, error: NSError?) -> Void in
            receivedProducts = products
            receivedIsLastPage = isLastPage
            receivedError = error
        }
        
        describe("product retrieval") {
            beforeEach {
                sut = LGProductsService(baseURL: "http://devel.api.letgo.com")
                receivedProducts = nil
                receivedIsLastPage = nil
                receivedError = nil
                self.removeAllStubs()
            }
            
            context("first page") {
                beforeEach {
                    let path = NSBundle(forClass: self.classForCoder).pathForResource("ProductsOK_FirstPage", ofType: "json")
                    let data = NSData(contentsOfFile: path!)!
                    let body : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)
                    self.stub(uri(LGProductsService.endpoint), builder: json(body, status: 200))

                    let coordinates = LGLocationCoordinates2D(latitude: 41.404819, longitude: 2.154288)
                    let accessToken = "NDMyNGU2ODhiZTk3YjdhZWZhNmY0YTRmYzY4NGNmMDY2NmVkYjJlMTNiYTAxYjBhYjM4Mjg2ZTJlODBhOTUwMg"

                    let params = RetrieveProductsParams(coordinates: coordinates, accessToken: accessToken)
                    sut.retrieveProductsWithParams(params, completion: completion)
                }
                it("should receive products") {
                    expect(receivedProducts).toEventuallyNot(beNil())
                    expect(receivedProducts).toEventuallyNot(beEmpty())
                }
                it("should not be the last page") {
                    expect(receivedIsLastPage).toEventuallyNot(beNil())
                    expect(receivedIsLastPage).toEventually(beFalse())
                }
                it("should receive no error") {
                    expect(receivedError).toEventually(beNil())
                }
            }
            
            context("last page") {
                beforeEach {
                    let path = NSBundle(forClass: self.classForCoder).pathForResource("ProductsOK_LastPage", ofType: "json")
                    let data = NSData(contentsOfFile: path!)!
                    let body : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)
                    self.stub(uri(LGProductsService.endpoint), builder: json(body, status: 200))
                    
                    let coordinates = LGLocationCoordinates2D(latitude: 41.404819, longitude: 2.154288)
                    let accessToken = "NDMyNGU2ODhiZTk3YjdhZWZhNmY0YTRmYzY4NGNmMDY2NmVkYjJlMTNiYTAxYjBhYjM4Mjg2ZTJlODBhOTUwMg"
                    
                    let params = RetrieveProductsParams(coordinates: coordinates, accessToken: accessToken)
                    sut.retrieveProductsWithParams(params, completion: completion)
                }
                it("should receive products") {
                    expect(receivedProducts).toEventuallyNot(beNil())
                    expect(receivedProducts).toEventuallyNot(beEmpty())
                }
                it("should be the last page") {
                    expect(receivedIsLastPage).toEventuallyNot(beNil())
                    expect(receivedIsLastPage).toEventually(beTrue())
                }
                it("should receive no error") {
                    expect(receivedError).toEventually(beNil())
                }
            }

            context("token expired") {
                beforeEach {
                    let path = NSBundle(forClass: self.classForCoder).pathForResource("ProductsKO_TokenExpired", ofType: "json")
                    let data = NSData(contentsOfFile: path!)!
                    let body : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)
                    self.stub(uri(LGProductsService.endpoint), builder: json(body, status: 401))
                    
                    let coordinates = LGLocationCoordinates2D(latitude: 41.404819, longitude: 2.154288)
                    let accessToken = "NDMyNGU2ODhiZTk3YjdhZWZhNmY0YTRmYzY4NGNmMDY2NmVkYjJlMTNiYTAxYjBhYjM4Mjg2ZTJlODBhOTUwMg"
                    
                    let params = RetrieveProductsParams(coordinates: coordinates, accessToken: accessToken)
                    sut.retrieveProductsWithParams(params, completion: completion)
                }
                it("should not receive products") {
                    expect(receivedProducts).toEventually(beNil())
                }
                it("should receive an error") {
                    expect(receivedError).toEventuallyNot(beNil())
                }
            }
        }
    }
}
