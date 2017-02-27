//
//  LocalUserSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 31/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import Quick
import Nimble
import Argo
import LGCoreKit
@testable import LetGo


class LocalUserSpec: QuickSpec {
    
    override func spec() {
        
        var sut : LocalUser!
        var mockUserProduct: MockUserProduct!
        var mockUser: MockUser!
        var chatInterlocutor: MockChatInterlocutor!
        
        describe("init") {
           
            context("init with userProduct") {
                beforeEach {
                    mockUserProduct = MockUserProduct.makeMock()
                    mockUserProduct.objectId = String.makeRandom()
                    mockUserProduct.name = String.makeRandom()
                    sut = LocalUser(userProduct: mockUserProduct)
                }
                it("object not nil") {
                    expect(sut).notTo(beNil())
                }
                it("object Id is equal") {
                    expect(sut.objectId).to(equal(mockUserProduct.objectId))
                }
                it("name is equal") {
                    expect(sut.name).to(equal(mockUserProduct.name))
                }
                it("postalAddress is equal") {
                    expect(sut.postalAddress) == mockUserProduct.postalAddress
                }
                it("accounts is empty") {
                    expect(sut.accounts.count) == 0
                }
                it("ratingAverage is nil") {
                    expect(sut.ratingAverage).to(beNil())
                }
                it("ratingCount is 0") {
                    expect(sut.ratingCount).to(equal(0))
                }
                
            }
            context("init with user") {
                beforeEach {
                    mockUser = MockUser.makeMock()
                    mockUser.objectId = String.makeRandom()
                    mockUser.name = String.makeRandom()
                    sut = LocalUser(user: mockUser)
                }
                it("object not nil") {
                    expect(sut).notTo(beNil())
                }
                it("object Id is equal") {
                    expect(sut.objectId).to(equal(mockUser.objectId))
                }
                it("name is equal") {
                    expect(sut.name).to(equal(mockUser.name))
                }
                it("postalAddress is equal") {
                    expect(sut.postalAddress) == mockUser.postalAddress
                }
                it("accounts is empty") {
                    expect(sut.accounts.count) == mockUser.accounts.count
                }
                it("ratingCount is equal") {
                    expect(sut.ratingCount).to(equal(mockUser.ratingCount))
                }
            }
            context("init with chatInterlocutor") {
                beforeEach {
                    chatInterlocutor = MockChatInterlocutor.makeMock()
                    sut = LocalUser(chatInterlocutor: chatInterlocutor)
                }
                it("object not nil") {
                    expect(sut).notTo(beNil())
                }
                it("name is equal") {
                    expect(sut.name).to(equal(chatInterlocutor.name))
                }
                it("banned is equal") {
                    expect(sut.banned).to(equal(chatInterlocutor.isBanned))
                }
                it("status is equal") {
                    expect(sut.status).to(equal(chatInterlocutor.status))
                }
                it("postalAddress is empty") {
                    expect(sut.postalAddress) == PostalAddress.emptyAddress()
                }
                it("accounts is empty") {
                    expect(sut.accounts.count) == 0
                }
                it("ratingCount is 0") {
                    expect(sut.ratingCount).to(equal(0))
                }
            }
        }
    }
}
