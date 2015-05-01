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
        
        var receivedProducts: [PartialProduct]?
        var receivedError: LGError?
        
        let completion = { (products: [PartialProduct]?, error: LGError?) -> Void in
            receivedProducts = products
            receivedError = error
        }
        
        describe("product retrieval") {
            beforeEach {
                sut = LGProductsService(baseURL: "http://api.letgo.com")
                receivedProducts = nil
                receivedError = nil
                self.removeAllStubs()
            }
            
            context("with coordinates and non-expired access token") {
                beforeEach {
                    let body = "{\"data\":[{\"object_id\":\"fYAHyLsEVf\",\"category_id\":\"4\",\"name\":\"Calentador de agua\",\"price\":\"80\",\"currency\":\"EUR\",\"created_at\":\"2015-04-15 10:12:21\",\"status\":\"1\",\"img_url_thumb\":\"/50/a2/f4/5f/b8ede3d0f6afacde9f0001f2a2753c6b_thumb.jpg\",\"distance_type\":\"ML\",\"distance\":\"9.65026566268547\",\"image_dimensions\":{\"width\":200,\"height\":150}}],\"info\":{\"total_products\":\"475\",\"offset\":\"0\"}}"
                    self.stub(uri(LGProductsService.endpoint), builder: json(body, status: 200))
                    
                    let coordinates = CLLocationCoordinate2D(latitude: 41.404819, longitude: 2.154288)
                    let accessToken = "NDMyNGU2ODhiZTk3YjdhZWZhNmY0YTRmYzY4NGNmMDY2NmVkYjJlMTNiYTAxYjBhYjM4Mjg2ZTJlODBhOTUwMg"
                    let params = RetrieveProductsParams(coordinates: coordinates, accessToken: accessToken)!
                    sut.retrieveProductsWithParams(params, completion: completion)
                }
                it("should receive products") {
                    expect(receivedProducts).toEventuallyNot(beNil())
                    expect(receivedProducts).toEventuallyNot(beEmpty())
                }
                it("should receive no error") {
                    expect(receivedError).toEventually(beNil())
                }
            }
            
            context("with coordinates and expired access token") {
                beforeEach {
                    let body = "{\"error\":\"invalid_grant\",\"error_description\":\"The access token provided is invalid.\"}"
                    self.stub(uri(LGProductsService.endpoint), builder: json(body, status: 401))
                    
                    let coordinates = CLLocationCoordinate2D(latitude: 41.404819, longitude: 2.154288)
                    let accessToken = "NDMyNGU2ODhiZTk3YjdhZWZhNmY0YTRmYzY4NGNmMDY2NmVkYjJlMTNiYTAxYjBhYjM4Mjg2ZTJlODBhOTUwMg"
                    let params = RetrieveProductsParams(coordinates: coordinates, accessToken: accessToken)!
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
