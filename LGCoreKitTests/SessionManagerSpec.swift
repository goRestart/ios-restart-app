//
//  SessionManagerSpec.swift
//  LGCoreKit
//
//  Created by AHL on 29/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

import Quick
import LGCoreKit
import Nimble

class MockSessionService: SessionService {
    func retrieveTokenWithParams(params: RetrieveTokenParams, completion: RetrieveTokenCompletion) {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            let sessionToken = LGSessionToken(accessToken: "", expirationDate: NSDate(timeIntervalSinceNow: -3600))
            completion(token: sessionToken, error: nil)
        }
    }
}

class SessionManagerSpec: QuickSpec {
    
    override func spec() {
        // Reset the user defaults
        let userDefaults = NSUserDefaults(suiteName: "test")!
        for key in userDefaults.dictionaryRepresentation().keys {
            userDefaults.removeObjectForKey(key as! String)
        }
        userDefaults.synchronize()
        
        describe("initial state") {
            let mockSessionService = MockSessionService()
            let sut: SessionManager = SessionManager(sessionService: mockSessionService, userDefaults: userDefaults)

            it("has no token") {
                expect(sut.sessionToken).to(beNil())
            }
            
            it("is not loading") {
                expect(sut.isLoading).to(beFalse())
            }
        }
        
        describe("token retrieval") {
            it("is loading and eventually not loading") {
                let mockSessionService = MockSessionService()
                let sut: SessionManager = SessionManager(sessionService: mockSessionService, userDefaults: userDefaults)
                sut.retrieveSessionTokenWithCompletion(nil)
                expect(sut.isLoading).to(beTrue())
                expect(sut.isLoading).toEventually(beFalse())
            }
            
            it("updates the token") {
                let mockSessionService = MockSessionService()
                let sut: SessionManager = SessionManager(sessionService: mockSessionService, userDefaults: userDefaults)
                sut.retrieveSessionTokenWithCompletion(nil)
                expect(sut.sessionToken).toEventuallyNot(beNil())
            }
            
            it("has token on next initializations") {
                let mockSessionService = MockSessionService()
                let sut: SessionManager = SessionManager(sessionService: mockSessionService, userDefaults: userDefaults)
                expect(sut.sessionToken).notTo(beNil())
            }
        }
        
        
    }
}