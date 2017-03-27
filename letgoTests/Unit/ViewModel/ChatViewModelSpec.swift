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
            
            func buildChatViewModel() {
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
                let myUser = MockMyUser.makeMock()
                myUserRepository.myUserVar.value = myUser
                chatRepository = MockChatRepository()
                productRepository = MockProductRepository()
                userRepository = MockUserRepository()
                stickersRepository  = MockStickersRepository()
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
            
            fdescribe("direct messages") {
                describe("quick answer") {
                    context("success first message") {
                        beforeEach {
                            
                            chatRepository.indexMessagesResult = ChatMessagesResult(value: [])
                            chatRepository.indexConversationsResult = ChatConversationsResult(value: MockChatConversation.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
                            chatRepository.showConversationResult = ChatConversationResult(value: MockChatConversation.makeMock())
                            chatRepository.commandResult = ChatCommandResult(value: Void())
                            chatRepository.unreadMessagesResult = ChatUnreadMessagesResult(value: MockChatUnreadMessages.makeMock())
                            chatRepository.chatStatusPublishSubject.onNext(.openAuthenticated)
                            
                            var chatInterlocutor = MockChatInterlocutor.makeMock()
                            chatInterlocutor.status = .active
                            chatInterlocutor.isMuted = false
                            chatInterlocutor.isBanned = false
                            chatInterlocutor.hasMutedYou = false
                            let chatConversation = EmptyConversation(objectId: nil, unreadMessageCount: 0, lastMessageSentAt: nil, product: nil,
                                                                     interlocutor: chatInterlocutor, amISelling: true)
                            chatRepository.showConversationResult = ChatConversationResult(value: chatConversation)
                            chatRepository.commandResult = ChatCommandResult(value: Void())
                           // chatRepository.unreadMessagesResult = ChatUnreadMessagesResult(value: ChatUnreadMessagesResult.makeMock())
                         
                            
                           // chatRepository.chatStatusPublishSubject = PublishSubject<WSChatStatus>(.openAuthenticated)
                           // chatRepository.chatEventsPublishSubject = PublishSubject<ChatEvent>()
                            
                            buildChatViewModel()
                            sut.send(quickAnswer: .meetUp)
                        }
                        it("adds one element on messages") {
                            expect(messages.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.text]
                        }
                        it("tracks two events") {
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-ask-question", "user-sent-message"]
                        }
                    }
                  /*  context("success non first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(false)]
                            buildProductViewModel()
                            sut.sendQuickAnswer(quickAnswer: .meetUp)
                            
                            expect(tracker.trackedEvents.count).toEventually(equal(1))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.text]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["user-sent-message"]
                        }
                    }
                    context("failure") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(error: .notFound)]
                            buildProductViewModel()
                            sut.sendQuickAnswer(quickAnswer: .meetUp)
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.text]
                        }
                        describe("failure arrives") {
                            beforeEach {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(equal(true))
                            }
                            it("element is removed from directMessages") {
                                expect(directChatMessagesObserver.lastValue?.count) == 0
                            }
                            it("didn't track any message sent event") {
                                expect(tracker.trackedEvents.count) == 0
                            }
                        }
                    } */
                }
           /*     describe("text message") {
                    context("success first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(true)]
                            buildProductViewModel()
                            sut.sendDirectMessage("Hola que tal", isDefaultText: false)
                            
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == ["Hola que tal"]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-ask-question", "user-sent-message"]
                        }
                    }
                    context("success non first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(false)]
                            buildProductViewModel()
                            sut.sendDirectMessage("Hola que tal", isDefaultText: true)
                            
                            expect(tracker.trackedEvents.count).toEventually(equal(1))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == ["Hola que tal"]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["user-sent-message"]
                        }
                    }
                    context("failure") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(error: .notFound)]
                            buildProductViewModel()
                            sut.sendDirectMessage("Hola que tal", isDefaultText: true)
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == ["Hola que tal"]
                        }
                        describe("failure arrives") {
                            beforeEach {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(equal(true))
                            }
                            it("element is removed from directMessages") {
                                expect(directChatMessagesObserver.lastValue?.count) == 0
                            }
                            it("didn't track any message sent event") {
                                expect(tracker.trackedEvents.count) == 0
                            }
                        }
                    }
                } */
            }
            
            
        }
    }
}
