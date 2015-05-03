//
//  SessionManagerSpec.swift
//  LGCoreKit
//
//  Created by AHL on 29/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Bolts
import Quick
import LGCoreKit
import Nimble

class SessionManagerSpec: QuickSpec {
    
    override func spec() {
        var sut: SessionManager!
        var sessionService: MockSessionService!
        var userDefaults: NSUserDefaults!
        
        var receivedToken: SessionToken?
        var receivedError: NSError?
        
        let completion = { (task: BFTask!) -> AnyObject! in
            receivedToken = task.result as? SessionToken
            receivedError = task.error
            return nil
        }
        
        beforeEach {
            sessionService = MockSessionService()
            userDefaults = NSUserDefaults(suiteName: "test")!
            sut = SessionManager(sessionService: sessionService, userDefaults: userDefaults)
            
            receivedToken = nil
            receivedError = nil
        }
        
        afterEach {
            // Reset user defaults
            for key in userDefaults.dictionaryRepresentation().keys {
                userDefaults.removeObjectForKey(key as! String)
            }
            userDefaults.synchronize()
        }
        
        describe("initial state") {
            it("has no token") {
                expect(sut.sessionToken).to(beNil())
            }
        }
        
        describe("token retrieval") {
            
            context("successful response") {
                beforeEach {
                    sessionService.sessionToken = LGSessionToken(accessToken: "", expirationDate: NSDate())
                    sut.retrieveSessionToken().continueWithBlock(completion)
                }
                
                it("updates the token") {
                    expect(sut.sessionToken).toEventuallyNot(beNil())
                }
                
                it("receives the token as result") {
                    expect(receivedToken).toEventuallyNot(beNil())
                }
            }
            
            context("error response") {
                beforeEach {
                    sessionService.error = NSError(code: LGErrorCode.UnexpectedServerResponse)
                    sut.retrieveSessionToken().continueWithBlock(completion)
                }
                
                it("receives an error and does not update the token") {
                    expect(receivedError).toEventuallyNot(beNil())
                    expect(sut.sessionToken).toEventually(beNil())
                }
            }
        }
        
        describe("initialization after first retrieval") {
            it("has token") {
                sessionService.sessionToken = LGSessionToken(accessToken: "", expirationDate: NSDate())

                sut.retrieveSessionToken()
                expect(sut.sessionToken).toEventuallyNot(beNil())
                
                sut = SessionManager(sessionService: sessionService, userDefaults: userDefaults)
                expect(sut.sessionToken).notTo(beNil())
            }
        }
    }
}