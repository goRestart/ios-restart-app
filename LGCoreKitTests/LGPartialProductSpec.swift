//
//  LGPartialProductSpec.swift
//  LGCoreKit
//
//  Created by AHL on 1/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Quick
import LGCoreKit
import Nimble
import SwiftyJSON

class LGPartialProductSpec: QuickSpec {
    
    override func spec() {
        describe("initialization with a valid full JSON") {
            // Given
            let jsonString = "{\"object_id\":\"fYAHyLsEVf\",\"category_id\":\"4\",\"name\":\"Calentador de agua\",\"price\":\"80\",\"currency\":\"EUR\",\"created_at\":\"2015-04-15 10:12:21\",\"status\":\"1\",\"img_url_thumb\":\"/50/a2/f4/5f/b8ede3d0f6afacde9f0001f2a2753c6b_thumb.jpg\",\"distance_type\":\"ML\",\"distance\":\"9.65026566268547\",\"image_dimensions\":{\"width\":200,\"height\":150}}"
            let jsonData: NSData! = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            let json = JSON(data: jsonData)
            
            // When
            let sut: PartialProduct = LGPartialProduct(json: json)
            
            // Then
            it("should have its fields as expected") {
                expect(sut.objectId).notTo(beNil())
                expect(sut.createdAt).notTo(beNil())
                expect(sut.price).notTo(beNil())
                expect(sut.currency).notTo(beNil())
                expect(sut.distance).notTo(beNil())
                expect(sut.distanceType).notTo(beNil())
                expect(sut.categoryId).notTo(beNil())
                expect(sut.status).notTo(beNil())
                expect(sut.thumbnailURL).notTo(beNil())
                expect(sut.thumbnailSize).notTo(beNil())
                
                expect(sut.objectId).to(equal("fYAHyLsEVf"))
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                expect(sut.createdAt).to(equal(dateFormatter.dateFromString("2015-04-15 10:12:21")))
                expect(sut.name).to(equal("Calentador de agua"))
                expect(sut.price).to(equal(80))
                expect(sut.currency).to(equal(Currency.EUR))
                expect(sut.distance).to(beCloseTo(9.65026566268547))
                expect(sut.distanceType).to(equal(DistanceType.Mi))
                expect(sut.categoryId).to(equal(4))
                expect(sut.status).to(equal(ProductStatus.Approved))
                expect(sut.thumbnailURL).to(equal("/50/a2/f4/5f/b8ede3d0f6afacde9f0001f2a2753c6b_thumb.jpg"))
                expect(sut.thumbnailSize).to(equal(LGSize(width: 200, height: 150)))
            }
        }
    }
}

