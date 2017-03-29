//
//  LocalChatSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 01/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import Quick
import Nimble
import Argo
import LGCoreKit
@testable import LetGoGodMode


class LocalChatSpec: QuickSpec {
    
    override func spec() {
        
        var sut : LocalChat!
        var userListing: MockUserListing!
        var product: MockProduct!
        
        describe("init") {
            context("init with userListing nil") {
                beforeEach {
                    product = MockProduct.makeMock()
                    userListing = nil
                    sut = LocalChat(listing: .product(product), myUserProduct: userListing)
                }
                it("objectId in userTo is the user product") {
                    expect(sut.userTo.objectId) == product.user.objectId
                    
                }
                it("userFrom is an empty user") {
                    expect(sut.userFrom.postalAddress) == PostalAddress.emptyAddress()
                }
            }
            
            context("init with a userListing") {
                beforeEach {
                    product = MockProduct.makeMock()
                    userListing = MockUserListing.makeMock()
                    sut = LocalChat(listing: .product(product), myUserProduct: userListing)
                }
                it("objectId in userTo is the user product") {
                    expect(sut.userTo.objectId) == product.user.objectId
                    
                }
                it("objectId userFrom is userListing object Id") {
                    expect(sut.userFrom.objectId) == userListing.objectId
                }
            }
        }
    }
}
