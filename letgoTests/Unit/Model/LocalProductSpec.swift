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
        var mockChatConversation: MockChatConversation!
        var mockMyUser: MockMyUser!

        
        describe("init") {
            beforeEach {
                mockChatConversation = MockChatConversation.makeMock()
                mockMyUser = MockMyUser.makeMock()
            }
            context("init being me a seller") {
                beforeEach {
                    mockChatConversation.amISelling = true
                    sut = LocalProduct(chatConversation: mockChatConversation,
                                       myUser: mockMyUser)
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
                    mockChatConversation.amISelling = false
                    sut = LocalProduct(chatConversation: mockChatConversation,
                                       myUser: mockMyUser)
                }

                it("name is chat interlocutorname") {
                    expect(sut.user.name).to(equal(mockChatConversation.interlocutor!.name))
                }
                it("isBanned attribute is the same than chatInterlocutor") {
                    expect(sut.user.banned).to(equal(mockChatConversation.interlocutor?.isBanned))
                }
            }
        }
    }
}
