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


class LocalProductSpec: QuickSpec {
    
    override func spec() {
        
        var sut : LocalProduct!
        var mockMyUser: MockMyUser!
        var mockChatConversation: MockChatConversation!
        
        describe("init") {
            context("init being me a seller") {
                beforeEach {
                    let postalAddress = PostalAddress(address: "Manuel Murguia", city: "Ourense", zipCode: "32005", state: "Ourense", countryCode: "GAL", country: "Galicia")
                    let mockAccount = MockAccount(provider: .facebook, verified: true)
                    
                    mockMyUser = MockMyUser(objectId: "1234", name: "Juan", avatar: nil, postalAddress: postalAddress, accounts: [mockAccount], ratingAverage: 5, ratingCount: 1, status: .active, isDummy: false, email: nil, location: nil, localeIdentifier: nil)
                    
                    mockChatConversation = MockChatConversation(unreadMessage: 5, lastMessageSentAt: Date(), product: MockChatProduct(), interlocutor: nil, amISelling: true)
                    
                    sut = LocalProduct(chatConversation: mockChatConversation, myUser: mockMyUser)
                }
                it("postal address is myUser postal address") {
                   expect(sut.user.postalAddress).to(equal(mockMyUser.postalAddress))
                }
                it("isDammy attribute is the same than myUser") {
                    expect(sut.user.isDummy).to(equal(mockMyUser.isDummy))
                }
                it("objectId is the same than myUser") {
                    expect(sut.user.objectId).to(equal(mockMyUser.objectId))
                }
            }
            
            context("init being me the buyer") {
                beforeEach {
                    let postalAddress = PostalAddress(address: "Manuel Murguia", city: "Ourense", zipCode: "32005", state: "Ourense", countryCode: "GAL", country: "Galicia")
                    let mockAccount = MockAccount(provider: .facebook, verified: true)
                    
                    mockMyUser = MockMyUser(objectId: "1234", name: "Juan", avatar: nil, postalAddress: postalAddress, accounts: [mockAccount], ratingAverage: 5, ratingCount: 1, status: .active, isDummy: false, email: nil, location: nil, localeIdentifier: nil)
                    
                    let chatInterlocutor = MockChatInterlocutor(name: "Other User", avatar: nil, isBanned: false, isMuted: false, hasMutedYou: false, status: .active)
                    
                    mockChatConversation = MockChatConversation(unreadMessage: 5, lastMessageSentAt: Date(), product: MockChatProduct(), interlocutor: chatInterlocutor, amISelling: false)
                    
                    sut = LocalProduct(chatConversation: mockChatConversation, myUser: mockMyUser)
                }
                
                it("name  is chat interlocutorname") {
                    expect(sut.user.name).to(equal(mockChatConversation.interlocutor!.name))
                }
                it("isBanned attribute is the same than chatInterlocutor") {
                    expect(sut.user.banned).to(equal(mockChatConversation.interlocutor?.isBanned))
                }
            }
        }
    }
}
