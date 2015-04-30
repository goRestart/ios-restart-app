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

class SessionManagerSpec: QuickSpec {
    
    override func spec() {
        var sut: SessionManager!
        var sessionService: MockSessionService!
        var userDefaults: NSUserDefaults!
        
        beforeEach {
            sessionService = MockSessionService()
            userDefaults = NSUserDefaults(suiteName: "test")!
            sut = SessionManager(sessionService: sessionService, userDefaults: userDefaults)
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
            it("is not loading") {
                expect(sut.isLoading).to(beFalse())
            }
        }
        
        describe("token retrieval") {
            it("is loading and eventually not loading") {
                sut.retrieveSessionTokenWithCompletion(nil)
                expect(sut.isLoading).to(beTrue())
                expect(sut.isLoading).toEventually(beFalse())
            }
            it("updates the token") {
                sessionService.sessionToken = LGSessionToken(accessToken: "", expirationDate: NSDate())
                
                sut.retrieveSessionTokenWithCompletion(nil)
                expect(sut.sessionToken).toEventuallyNot(beNil())
            }
        }
        
        describe("initialization after first retrieval") {
            it("has token") {
                sessionService.sessionToken = LGSessionToken(accessToken: "", expirationDate: NSDate())
                sut.retrieveSessionTokenWithCompletion(nil)
                expect(sut.sessionToken).toEventuallyNot(beNil())
                
                sut = SessionManager(sessionService: sessionService, userDefaults: userDefaults)
                expect(sut.sessionToken).notTo(beNil())
            }
        }
    }
}