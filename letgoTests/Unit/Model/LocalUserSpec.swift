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
        
        fdescribe("init") {
           
            context("init with userProduct") {
                beforeEach {
                    let postalAddress = PostalAddress(address: "Manuel Murguia", city: "Ourense", zipCode: "32005", state: "Ourense", countryCode: "GAL", country: "Galicia")
                    mockUserProduct = MockUserProduct(objectId: "1234", name: "userProduct", avatar: nil, postalAddress: postalAddress , email: "juan.iglesias@letgo.com", location: nil, banned: true)
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
                    let accountMail = MockAccount(provider: .email, verified: true)
                    let postalAddress = PostalAddress(address: "Manuel Murguia", city: "Ourense", zipCode: "32005", state: "Ourense", countryCode: "GAL", country: "Galicia")
                    mockUser = MockUser(objectId: "1234", name: "Juan", avatar: nil, postalAddress: postalAddress, email: "juan.iglesias@letgo.com", location: nil, accounts: [accountMail], ratingAccount: 5)
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
                    chatInterlocutor = MockChatInterlocutor(name: "Juan", avatar: nil, isBanned: false, isMuted: false, hasMutedYou: false, status: .active)
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
