//
//  LGProductServiceSpec.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Quick
import LGCoreKit
import Nimble
import SwiftyJSON
import Timepiece

class LGProductServiceSpec: QuickSpec {
    
    override func spec() {
        EnvironmentProxy.sharedInstance.setEnvironmentType(.Development)
        let env: Environment = EnvironmentProxy.sharedInstance
        
        describe("a call with only coordinates") {
            let sut = LGProductsService(baseURL: env.apiBaseURL, sessionManager: SessionManager.sharedInstance)
            let coordinates = CLLocationCoordinate2D(latitude: 41.404819, longitude: 2.154288)
            let params = RetrieveProductsParams(coordinates: coordinates)!
            
            var receivedProducts: [PartialProduct]?
            var receivedError: LGError?
            let completion = { (products: [PartialProduct]?, error: LGError?) -> Void in
                receivedProducts = products
                receivedError = error
            }
            sut.retrieveProductsWithParams(params, completion: completion)
            
            it("should receive products") {
                expect(receivedProducts).toEventuallyNot(beNil())
            }
            
            it("should receive no error") {
                expect(receivedError).toEventually(beNil())
            }
        }
    }
}
