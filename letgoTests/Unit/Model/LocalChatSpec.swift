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
        var myUserProduct: MockUserProduct!
        var product: MockProduct!
        
        describe("init") {
            context("init with myUserProduct nil") {
                beforeEach {
                    product = MockProduct.makeMock()
                    myUserProduct = nil
                    sut = LocalChat(product: product, myUserProduct: myUserProduct)
                }
                it("objectId in userTo is the user product") {
                    expect(sut.userTo.objectId) == product.user.objectId
                    
                }
                it("userFrom is an empty user") {
                    expect(sut.userFrom.postalAddress) == PostalAddress.emptyAddress()
                }
            }
            
            context("init with a myUserProduct") {
                beforeEach {
                    product = MockProduct.makeMock()
                    myUserProduct = MockUserProduct.makeMock()
                    sut = LocalChat(product: product, myUserProduct: myUserProduct)
                }
                it("objectId in userTo is the user product") {
                    expect(sut.userTo.objectId) == product.user.objectId
                    
                }
                it("objectId userFrom is myUserProduct object Id") {
                    expect(sut.userFrom.objectId) == myUserProduct.objectId
                }
            }
        }
    }
}
