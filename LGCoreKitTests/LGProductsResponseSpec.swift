//
//  LGProductsResponseSpec.swift
//  LGCoreKit
//
//  Created by AHL on 1/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Quick
import LGCoreKit
import Nimble
import SwiftyJSON

class LGProductsResponseSpec: QuickSpec {
    
    override func spec() {
        var sut: LGProductsResponse!
        
        describe("initialization") {
            context("via json") {
                context("with one product") {
                    beforeEach {
                        let jsonString = "{\"data\":[{\"object_id\":\"Ie920Go2QX\",\"category_id\":\"4\",\"name\":\"Stainless Steel coffee pot\",\"price\":\"15\",\"currency\":\"USD\",\"created_at\":\"2015-04-21 14:39:17\",\"status\":\"1\",\"img_url_thumb\":\"/50/a2/f4/5f/b8ede3d0f6afacde9f0001f2a2753c6b_thumb.jpg\",\"distance_type\":\"KM\",\"image_dimensions\":{\"width\":200,\"height\":267}}],\"info\":{\"total_products\":\"475\",\"offset\":\"0\"}}"
                        let jsonData: NSData! = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
                        let json = JSON(data: jsonData)
                        sut = LGProductsResponse(json: json)
                    }

                    it("should return a non-nil object") {
                        expect(sut).notTo(beNil())
                    }
                    it("should have an item") {
                        expect(sut.products).notTo(beEmpty())
                        expect(sut.products.count).to(equal(1))
                    }
                    it("should have the paging info") {
                        expect(sut.totalProducts).notTo(beNil())
                        expect(sut.totalProducts).to(equal(475))
                        expect(sut.offset).notTo(beNil())
                        expect(sut.offset).to(equal(0))
                    }
                }
                
                context("with no products") {
                    beforeEach {
                        let jsonString = "{\"data\":[],\"info\":{\"total_products\":\"475\",\"offset\":\"0\"}}"
                        let jsonData: NSData! = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
                        let json = JSON(data: jsonData)
                        sut = LGProductsResponse(json: json)
                    }
                    
                    it("should return a non-nil object") {
                        expect(sut).notTo(beNil())
                    }
                    it("should not have items") {
                        expect(sut.products).to(beEmpty())
                    }
                    it("should have the paging info") {
                        expect(sut.totalProducts).notTo(beNil())
                        expect(sut.totalProducts).to(equal(475))
                        expect(sut.offset).notTo(beNil())
                        expect(sut.offset).to(equal(0))
                    }
                }
                
                context("with wrong paging info") {
                    context("without info") {
                        beforeEach {
                            let jsonString = "{\"data\":[]}"
                            let jsonData: NSData! = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
                            let json = JSON(data: jsonData)
                            sut = LGProductsResponse(json: json)
                        }
                    }
                    
                    context("with info but total products") {
                        beforeEach {
                            let jsonString = "{\"data\":[],\"info\":{\"offset\":\"0\"}}"
                            let jsonData: NSData! = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
                            let json = JSON(data: jsonData)
                            sut = LGProductsResponse(json: json)
                        }
                        
                        it("should return a nil object") {
                            expect(sut).to(beNil())
                        }
                    }
                    
                    context("with info but offset") {
                        beforeEach {
                            let jsonString = "{\"data\":[],\"info\":{\"total_products\":\"475\"}}"
                            let jsonData: NSData! = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
                            let json = JSON(data: jsonData)
                            sut = LGProductsResponse(json: json)
                        }
                        
                        it("should return a nil object") {
                            expect(sut).to(beNil())
                        }
                    }
                }
            }
        }
    }
}