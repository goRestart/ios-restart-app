//
//  ChatListViewModelSpec.swift
//  LetGo
//
//  Created by Dídac on 22/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Quick
import LetGo
import LGCoreKit
import Nimble
import Result

class ChatListViewModelSpec: QuickSpec, ChatListViewModelDelegate {

    var receivedViewModel: ChatListViewModel!

    override func spec() {
        var sut: ChatListViewModel!

        describe ("initial state") {

            context("default init") {
                beforeEach {
                    sut = ChatListViewModel()
                }
                it ("should not have chats yet") {
                    expect(sut.chatCount).to(equal(0))
                }
                it ("does not return a chat in any index") {
                    expect(sut.chatAtIndex(1)).to(beNil())
                }
            }

            context("init with params") {
                beforeEach {
                    let chatRepository = ChatRepository.sharedInstance
                    let chatOne = MockChat()
                    chatOne.objectId = "chatOne"
                    let chatTwo = MockChat()
                    chatTwo.objectId = "chatTwo"
                    let chats = [chatOne as Chat, chatTwo as Chat] 

                    sut = ChatListViewModel(chatRepository: chatRepository, chats: chats)
                }
                it ("should have the num of chats passed by parameter") {
                    expect(sut.chatCount).to(equal(2))
                }
                it ("does return a chat in any index inside chats params bounds") {
                    expect(sut.chatAtIndex(1)?.objectId).to(equal("chatTwo"))
                    expect(sut.chatAtIndex(100)).to(beNil())
                }
            }
        }

        describe("chats retrieval") {
            beforeEach {
                sut = ChatListViewModel()
                self.receivedViewModel = nil
                sut.delegate = self
                sut.updateConversations()
            }
            it("notifies the delegate") {
                expect(sut).to(beIdenticalTo(self.receivedViewModel))
            }
        }
    }

    // MARK: - ChatListViewModelDelegate

    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool) {
        self.receivedViewModel = viewModel
    }
    func didFailRetrievingChatList(viewModel: ChatListViewModel, error: ChatsRetrieveServiceError) {

    }
    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, nonEmptyChatList: Bool) {

    }
}