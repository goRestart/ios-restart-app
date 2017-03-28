//
//  ChatViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble
import Foundation


class ChatViewModelSpec: BaseViewModelSpec {
    override func spec() {
        
        var sut: ChatViewModel!
        
        var conversation: MockChatConversation!
        var myUserRepository: MockMyUserRepository!
        var chatRepository: MockChatRepository!
        var productRepository: MockProductRepository!
        var userRepository: MockUserRepository!
        var stickersRepository: MockStickersRepository!
        var tracker: MockTracker!
        var configManager: MockConfigManager!
        var sessionManager: MockSessionManager!
        var keyValueStorage: KeyValueStorage!
        var featureFlags: MockFeatureFlags!
        var source: EventParameterTypePage!
        var pushPermissionManager: MockPushPermissionsManager!
        var ratingManager: MockRatingManager!
        
        
        // Vars rx observers
        var scheduler: TestScheduler!
        var disposeBag: DisposeBag!
        var messages: TestableObserver<[ChatViewMessage]>!
        
        fdescribe("ChatViewModelSpec") {
            
            func buildChatViewModel(myUser: MockMyUser,
                                    chatMessages: [MockChatMessage],
                                    product: MockProduct,
                                    interlocutor: MockChatInterlocutor,
                                    chatConversation: MockChatConversation,
                                    user: MockUser) {
                
                
                myUserRepository.result = MyUserResult(value: myUser)
                myUserRepository.myUserVar.value = myUser
                
                chatRepository = MockChatRepository.makeMock()
                chatRepository.indexMessagesResult = ChatMessagesResult(value: chatMessages)
                chatRepository.chatStatusPublishSubject.onNext(.openAuthenticated)
                
                productRepository = MockProductRepository.makeMock()
                productRepository.productResult = ProductResult(value: product)
                productRepository.indexResult = ProductsResult(value: MockProduct.makeMocks(count: 5))
                
                chatRepository.showConversationResult = ChatConversationResult(value: chatConversation)
                chatRepository.commandResult = ChatCommandResult(value: Void())
                
                conversation = chatConversation
                
                userRepository = MockUserRepository.makeMock()
                
                userRepository.userResult = UserResult(value: user)
                userRepository.userUserRelationResult = UserUserRelationResult(value: MockUserUserRelation.makeMock())
                userRepository.emptyResult = UserVoidResult(value: Void())
                
                sut = ChatViewModel(conversation: conversation, myUserRepository: myUserRepository,
                                    chatRepository: chatRepository, productRepository: productRepository,
                                    userRepository: userRepository, stickersRepository: stickersRepository,
                                    tracker: tracker, configManager: configManager, sessionManager: sessionManager,
                                    keyValueStorage: keyValueStorage, navigator: nil, featureFlags: featureFlags,
                                    source: source, ratingManager: ratingManager, pushPermissionsManager: pushPermissionManager)
                
                disposeBag = DisposeBag()
                sut.messages.observable.bindTo(messages).addDisposableTo(disposeBag)
            }
            

            
            beforeEach {
                
                // init vars
                sut = nil
                conversation = MockChatConversation.makeMock()
                myUserRepository = MockMyUserRepository()
                chatRepository = MockChatRepository()
                productRepository = MockProductRepository()
                userRepository = MockUserRepository()
                stickersRepository  = MockStickersRepository.makeMock()
                tracker = MockTracker()
                configManager = MockConfigManager()
                sessionManager = MockSessionManager()
                keyValueStorage = KeyValueStorage()
                featureFlags = MockFeatureFlags()
                source = .chat
                pushPermissionManager = MockPushPermissionsManager()
                ratingManager = MockRatingManager()
                
                
                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                messages = scheduler.createObserver(Array<ChatViewMessage>.self)
                
            }
            afterEach {
                scheduler.stop()
                disposeBag = nil
            }
            
            /*   context("Review button") {
             context("there is less than two message for each user") {
             it("does not show review button") {
             
             }
             }
             context("no messages enough, send a message and it is enough") {
             it("show review button") {
             
             }
             }
             context("interlocutor has more than 2 messages.") {
             it("show review button") {
             
             }
             }
             } */
            
            describe("initialization") {
                beforeEach {
                    let mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                    let chatMessages: [MockChatMessage] = []
                    let productResult = self.makeMockProduct(with: .approved)
                    let chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                    let chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil)
                    let user = self.makeUser(with: .active, isDummy: false)
                    
                    buildChatViewModel(myUser: mockMyUser,
                                       chatMessages: chatMessages,
                                       product: productResult,
                                       interlocutor: chatInterlocutor,
                                       chatConversation: chatConversation,
                                       user: user)
                    sut.active = true
                }
                
            }
            
            describe("send message") {
                describe("new conversation") {
                    beforeEach {
                        let mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                        let chatMessages: [MockChatMessage] = []
                        let productResult = self.makeMockProduct(with: .approved)
                        let chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                        let chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil)
                        let user = self.makeUser(with: .active, isDummy: false)
                        
                        buildChatViewModel(myUser: mockMyUser,
                                           chatMessages: chatMessages,
                                           product: productResult,
                                           interlocutor: chatInterlocutor,
                                           chatConversation: chatConversation,
                                           user: user)
                        sut.active = true
                    }
                    context("quick answer") {
                        beforeEach {
                            sut.send(quickAnswer: .meetUp)
                            expect(tracker.trackedEvents.count).toEventually(equal(3))
                        }
                        it("adds one element on messages") {
                            expect(messages.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.text]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "product-detail-ask-question", "user-sent-message"]
                        }
                    }
                    context("custom text") {
                        beforeEach {
                            sut.send(text: "text")
                            expect(tracker.trackedEvents.count).toEventually(equal(3))
                        }
                        it("adds one element on messages") {
                            expect(messages.lastValue?.map{ $0.value }) == ["text"]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "product-detail-ask-question", "user-sent-message"]
                        }
                    }
                }
                
                describe("already existing conversation") {
                    beforeEach {
                        let mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                        let chatMessages: [MockChatMessage] = [MockChatMessage.makeMock()]
                        let productResult = self.makeMockProduct(with: .approved)
                        let chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                        let chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date())
                        let user = self.makeUser(with: .active, isDummy: false)
                        
                        buildChatViewModel(myUser: mockMyUser,
                                           chatMessages: chatMessages,
                                           product: productResult,
                                           interlocutor: chatInterlocutor,
                                           chatConversation: chatConversation,
                                           user: user)
                        
                        sut.active = true
                    }
                    context("quick answer") {
                        beforeEach {
                            sut.send(quickAnswer: .meetUp)
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("adds one element on messages") {
                            expect(messages.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.text]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message"]
                        }
                    }
                    context("custom text") {
                        beforeEach {
                            
                            sut.send(text: "text")
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("adds one element on messages") {
                            expect(messages.lastValue?.map{ $0.value }) == ["text"]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message"]
                        }
                    }
                }
                
            }
        }
    }
}

extension ChatViewModelSpec {
    func makeMockMyUser(with userStatus: UserStatus, isDummy: Bool) -> MockMyUser {
        var myUser = MockMyUser.makeMock()
        myUser.status = userStatus
        myUser.isDummy = isDummy
        return myUser
    }
    
    func makeMockProduct(with status: ProductStatus) -> MockProduct {
        var productResult = MockProduct.makeMock()
        productResult.status = status
        return productResult
    }
    
    func makeChatInterlocutor(with status: UserStatus, isMuted: Bool, isBanned: Bool, hasMutedYou: Bool) -> MockChatInterlocutor {
        var chatInterlocutor = MockChatInterlocutor.makeMock()
        chatInterlocutor.status = status
        chatInterlocutor.isMuted = isMuted
        chatInterlocutor.isBanned = isBanned
        chatInterlocutor.hasMutedYou = hasMutedYou
        return chatInterlocutor
    }
    
    func makeChatConversation(with interlocutor: ChatInterlocutor, unreadMessageCount: Int, lastMessageSentAt: Date?) -> MockChatConversation {
        var chatConversation = MockChatConversation.makeMock()
        chatConversation.interlocutor = interlocutor
        chatConversation.unreadMessageCount = unreadMessageCount
        chatConversation.lastMessageSentAt = lastMessageSentAt
        return chatConversation
    }
    
    func makeUser(with status: UserStatus, isDummy: Bool) -> MockUser {
        var user = MockUser.makeMock()
        user.status = status
        user.isDummy = isDummy
        return user
    }
}
