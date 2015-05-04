//
//  LGSessionSpec.swift
//  letgopodstry
//
//  Created by AHL on 29/4/15.
//  Copyright (c) 2015 LetGo. All rights reserved.
//

import Quick
import LGCoreKit
import Nimble
import SwiftyJSON
import Timepiece

class LGSessionTokenSpec: QuickSpec {
    
    override func spec() {
        describe("initialization with a valid JSON") {  
            // Given
            let jsonString = "{\"access_token\":\"ODNhMDBhN2Y1MWRkYmM1ODQwOWMxNmEyODViYzk2ZGY1NWQ5YWU4NzczMDgyOGFiMjFkMjJkNDdjODJhMjA3Mw\",\"expires_in\":3600,\"token_type\":\"bearer\",\"scope\":\"user\"}"
            let jsonData: NSData! = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            let json = JSON(data: jsonData)
            
            // When
            let sut: SessionToken! = LGSessionToken(json: json)
            
            // Then
            it("should return a non-nil object") {
                expect(sut).notTo(beNil())
            }
            it("should have the access token") {
                expect(sut.accessToken).to(equal("ODNhMDBhN2Y1MWRkYmM1ODQwOWMxNmEyODViYzk2ZGY1NWQ5YWU4NzczMDgyOGFiMjFkMjJkNDdjODJhMjA3Mw"))
            }
            it("should have be not expired") {
                let now = NSDate()
                let expiration = now + 3600.seconds
                expect(sut.expirationDate.timeIntervalSinceNow).to(beCloseTo(expiration.timeIntervalSinceNow, within: 1000))
                expect(sut.isExpired()).to(beFalse())
            }
        }
        
        describe("initialization with an invalid JSON") {
            
            // Given
            let jsonString = "{\"random_key\":\"random_value\"}"
            let jsonData: NSData! = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            let json = JSON(data: jsonData)
            
            // When
            let sut: SessionToken! = LGSessionToken(json: json)
            
            // Then
            it("should return a nil object") {
                expect(sut).to(beNil())
            }
        }
    }
}