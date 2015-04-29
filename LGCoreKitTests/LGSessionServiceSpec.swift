//
//  LGSessionServiceSpec.swift
//  letgopodstry
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 LetGo. All rights reserved.
//

import Quick
import LGCoreKit
import Nimble

class LGSessionServiceSpec: QuickSpec {
    
    override func spec() {
        EnvironmentProxy.sharedInstance.setEnvironmentType(.Development)
        let env: Environment = EnvironmentProxy.sharedInstance
        
        describe("a call with valid client id and client secret") {
            // Given
            let sut: SessionService = LGSessionService(baseURL: env.apiBaseURL)
            let params = RetrieveTokenParams(clientId: "2_63roc3zwvhc0cgkkcs0wg0ogkwks0wcg8kgswcswsggg8ogokk", clientSecret: "64szvwjvm1wkwgogswsgccoco4ggckkwg444kswccg0404g040")
            
            // When
            var receivedToken: SessionToken?
            var receivedError: LGError?
            
            let completion = { (token: SessionToken?, error: LGError?) -> Void in
                receivedToken = token
                receivedError = error
            }
            sut.retrieveTokenWithParams(params, completion: completion)
            
            // Then
            it("should receive a valid non-expired session token") {
                expect(receivedToken).toEventuallyNot(beNil())
                expect(receivedToken?.isExpired()).to(beFalse())
            }
            it("should receive no error") {
                expect(receivedError).toEventually(beNil())
            }
        }
        
        describe("a call with invalid client id and client secret") {
            // Given
            let sut: SessionService = LGSessionService(baseURL: "http://devel.api.letgo.com")
            let params = RetrieveTokenParams(clientId: "invalid", clientSecret: "invalid")
            
            // When
            var receivedToken: SessionToken?
            var receivedError: LGError?
            
            let completion = { (token: SessionToken?, error: LGError?) -> Void in
                receivedToken = token
                receivedError = error
            }
            sut.retrieveTokenWithParams(params, completion: completion)
            
            // Then
            it("should receive no session token") {
                expect(receivedToken).toEventually(beNil())
            }
            it("should receive an error") {
                expect(receivedError).toEventuallyNot(beNil())
            }
        }
    }
}