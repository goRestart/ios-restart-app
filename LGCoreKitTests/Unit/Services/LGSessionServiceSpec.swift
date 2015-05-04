//
//  LGSessionServiceSpec.swift
//  letgopodstry
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 LetGo. All rights reserved.
//

import Quick
import LGCoreKit
import Mockingjay
import Nimble

class LGSessionServiceSpec: QuickSpec {
    
    override func spec() {
        var sut: SessionService!
        
        var receivedToken: SessionToken?
        var receivedError: NSError?
        
        let completion = { (token: SessionToken?, error: NSError?) -> Void in
            receivedToken = token
            receivedError = error
        }
        
        describe("token retrieval") {
            beforeEach {
                sut = LGSessionService(baseURL: "http://devel.api.letgo.com")
                receivedToken = nil
                receivedError = nil
                self.removeAllStubs()
            }
            
            context("valid client id and client secret") {
                beforeEach {
                    let body = [ "access_token": "NDMyNGU2ODhiZTk3YjdhZWZhNmY0YTRmYzY4NGNmMDY2NmVkYjJlMTNiYTAxYjBhYjM4Mjg2ZTJlODBhOTUwMg",
                        "expires_in": 3600,
                        "token_type":"bearer",
                        "scope":"user"]
                    self.stub(uri(LGSessionService.endpoint), builder: json(body, status: 200))
                    
                    let params = RetrieveTokenParams(clientId: "2_63roc3zwvhc0cgkkcs0wg0ogkwks0wcg8kgswcswsggg8ogokk", clientSecret: "64szvwjvm1wkwgogswsgccoco4ggckkwg444kswccg0404g040")
                    sut.retrieveTokenWithParams(params, completion: completion)
                }
                
                it("should receive a non-expired session token") {
                    expect(receivedToken).toEventuallyNot(beNil())
                    expect(receivedToken?.isExpired()).to(beFalse())
                }
                it("should receive no error") {
                    expect(receivedError).toEventually(beNil())
                }
            }
            
            context("invalid client id and client secret") {
                beforeEach {
                    let body = [ "error": "invalid_client", "error_description": "The client credentials are invalid"]
                    self.stub(uri(LGSessionService.endpoint), builder: json(body, status: 400))
                    
                    let params = RetrieveTokenParams(clientId: "invalid", clientSecret: "invalid")
                    sut.retrieveTokenWithParams(params, completion: completion)
                }
                
                it("should receive no session token") {
                    expect(receivedToken).toEventually(beNil())
                }
                it("should receive an error") {
                    expect(receivedError).toEventuallyNot(beNil())
                }
            }
            
            context("unexpected json server response") {
                beforeEach {
                    let body = [ "whatever": "whatever" ]
                    self.stub(uri(LGSessionService.endpoint), builder: json(body, status: 500))
                    
                    let params = RetrieveTokenParams(clientId: "whatever", clientSecret: "whatever")
                    sut.retrieveTokenWithParams(params, completion: completion)
                }
                
                it("should receive no session token") {
                    expect(receivedToken).toEventually(beNil())
                }
                it("should receive an error") {
                    expect(receivedError).toEventuallyNot(beNil())
                    println("\(receivedError)")
                }
            }
            
            context("unexpected response") {
                beforeEach {
                    let error = NSError()
                    self.stub(uri(LGSessionService.endpoint), builder: http(status: 500))
                    
                    let params = RetrieveTokenParams(clientId: "whatever", clientSecret: "whatever")
                    sut.retrieveTokenWithParams(params, completion: completion)
                }
                
                it("should receive no session token") {
                    expect(receivedToken).toEventually(beNil())
                }
                it("should receive an error") {
                    expect(receivedError).toEventuallyNot(beNil())
                    println("\(receivedError)")
                }
            }
        }
    }
}