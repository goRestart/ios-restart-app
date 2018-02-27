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
    
    // Control vars:
    var safetyTipsShown: Bool!
    var textFieldCleaned: Bool!
    
    override func spec() {
        
        var sut: ChatViewModel!
        
        var conversation: MockChatConversation!
        var myUserRepository: MockMyUserRepository!
        var chatRepository: MockChatRepository!
        var listingRepository: MockListingRepository!
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

        
        
        // Vars to modify on tests:
        var mockMyUser: MockMyUser!
        var chatMessages: [MockChatMessage]!
        var productResult: MockProduct!
        var chatInterlocutor: MockChatInterlocutor!
        var user: MockUser!
        var chatConversation: MockChatConversation!
        var relatedCounter: Int!
        var listingsRelated: [Listing] = []
        
        // Vars rx observers
        var scheduler: TestScheduler!
        var disposeBag: DisposeBag!
        var messages: TestableObserver<[ChatViewMessage]>!
        var relatedListingsStateObserver: TestableObserver<ChatRelatedItemsState>!
        
        describe("ChatViewModelSpec") {
            
            func buildChatViewModel(myUser: MockMyUser,
                                    chatMessages: [MockChatMessage],
                                    product: MockProduct,
                                    chatConversation: MockChatConversation,
                                    commandSuccess: Bool = true,
                                    user: MockUser,
                                    chatRepoError: ChatRepositoryError? = nil,
                                    openChatAutomaticMessage: ChatWrapperMessageType? = nil,
                                    isProfessional: Bool = false) {
                
                safetyTipsShown = false
                textFieldCleaned = false
                
                myUserRepository.result = MyUserResult(value: myUser)
                myUserRepository.myUserVar.value = myUser

                chatRepository.indexMessagesResult = ChatMessagesResult(value: chatMessages)
                chatRepository.chatStatusPublishSubject.onNext(.openAuthenticated)
                chatRepository.showConversationResult = ChatConversationResult(value: chatConversation)
                let repositoryError: RepositoryError
                if let chatRepoError = chatRepoError {
                    repositoryError = .wsChatError(error: chatRepoError)
                } else {
                    repositoryError = .internalError(message: "test")
                }

                let commandResult: ChatCommandResult = commandSuccess ? ChatCommandResult(value: Void()) : ChatCommandResult(error: repositoryError)
                chatRepository.sendMessageCommandResult = commandResult
                chatRepository.archiveCommandResult = commandResult
                chatRepository.unarchiveCommandResult = commandResult
                chatRepository.confirmReadCommandResult = commandResult
                chatRepository.confirmReceptionCommandResult = commandResult

                listingRepository.indexResult = ListingsResult(value: listingsRelated)
                listingRepository.productResult = ProductResult(value: product)

                userRepository.userResult = UserResult(value: user)
                userRepository.emptyResult = UserVoidResult(value: Void())

                conversation = chatConversation
                let predefinedMessage = String.makeRandom()
                sut = ChatViewModel(conversation: conversation, myUserRepository: myUserRepository,
                                    chatRepository: chatRepository, listingRepository: listingRepository,
                                    userRepository: userRepository, stickersRepository: stickersRepository,
                                    tracker: tracker, configManager: configManager, sessionManager: sessionManager,
                                    keyValueStorage: keyValueStorage, navigator: nil, featureFlags: featureFlags,
                                    source: source, ratingManager: ratingManager, pushPermissionsManager: pushPermissionManager,
                                    predefinedMessage: predefinedMessage, openChatAutomaticMessage: openChatAutomaticMessage,
                                    isProfessional: isProfessional)
                
                sut.delegate = self
                disposeBag = DisposeBag()
                sut.messages.observable.bind(to: messages).disposed(by: disposeBag)
                sut.relatedListingsState.asObservable().bind(to: relatedListingsStateObserver).disposed(by: disposeBag)
            }
            
            
            beforeEach {
                
                // init vars
                sut = nil
                myUserRepository = MockMyUserRepository()
                chatRepository = MockChatRepository()
                listingRepository = MockListingRepository()
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
                relatedListingsStateObserver = scheduler.createObserver(ChatRelatedItemsState.self)
                
            }
            afterEach {
                scheduler.stop()
                disposeBag = nil
                self.resetViewModelSpec()
            }
            
            
            
            describe("initialization") {
                beforeEach {
                    mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                    chatMessages = []
                    productResult = self.makeMockProduct(with: .approved)
                    chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                    user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                    
                }
                context("related products") {
                    context("being a seller") {
                        beforeEach {
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: true)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               user: user)
                            sut.active = true
                        }
                        it ("does not have related products") {
                            expect(sut.relatedListings.count).toEventually(equal(0))
                        }
                        it("related products states has only one value") {
                            expect(relatedListingsStateObserver.eventValues.count).toEventually(equal(1))
                        }
                        it("related products state is hidden") {
                            expect(relatedListingsStateObserver.lastValue).toEventually(equal(ChatRelatedItemsState.hidden))
                        }
                    }
                    context("being a buyer and listing sold") {
                        context("less than four related products") {
                            var listingId: String!
                            beforeEach {
                                productResult = self.makeMockProduct(with: .sold)
                                chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false, listingStatus: .sold)
                                relatedCounter = Int.random(1, ChatViewModel.maxRelatedListingsForExpressChat)
                                listingsRelated = Listing.makeMocks(count: relatedCounter)
                                buildChatViewModel(myUser: mockMyUser,
                                                   chatMessages: chatMessages,
                                                   product: productResult,
                                                   chatConversation: chatConversation,
                                                   user: user)
                                sut.active = true
                                expect(relatedListingsStateObserver.eventValues.count).toEventually(equal(1))
                            }
                            it ("has related products") {
                                expect(sut.relatedListings.count).toEventually(equal(relatedCounter))
                            }
                            it("related products state is visible") {
                                listingId = chatConversation.listing?.objectId
                                expect(relatedListingsStateObserver.eventValues).toEventually(equal([ChatRelatedItemsState.visible(listingId: listingId)]))
                            }
                        }
                        context("more than four related products") {
                            var listingId: String!
                            beforeEach {
                                productResult = self.makeMockProduct(with: .sold)
                                chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false, listingStatus: .sold)
                                listingsRelated = Listing.makeMocks(count: Int.random(ChatViewModel.maxRelatedListingsForExpressChat, 20))
                                buildChatViewModel(myUser: mockMyUser,
                                                   chatMessages: chatMessages,
                                                   product: productResult,
                                                   chatConversation: chatConversation,
                                                   user: user)
                                sut.active = true
                                expect(relatedListingsStateObserver.eventValues.count).toEventually(equal(1))
                            }
                            it ("has related products") {
                                expect(sut.relatedListings.count).toEventually(equal(ChatViewModel.maxRelatedListingsForExpressChat))
                            }
                            it("related products state is visible") {
                                listingId = chatConversation.listing?.objectId
                                expect(relatedListingsStateObserver.eventValues).toEventually(equal([ChatRelatedItemsState.visible(listingId: listingId)]))
                            }
                        }
                        
                    }
                    context("being a buyer and listing sold") {
                        var listingId: String!
                        beforeEach {
                            productResult = self.makeMockProduct(with: .sold)
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false, listingStatus: .sold)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               user: user)
                            sut.active = true
                            expect(relatedListingsStateObserver.eventValues.count).toEventually(equal(1))
                        }
                        it ("has related products") {
                            expect(sut.relatedListings.count).toEventually(equal(ChatViewModel.maxRelatedListingsForExpressChat))
                        }
                        it("related products state is visible") {
                            listingId = chatConversation.listing?.objectId
                            expect(relatedListingsStateObserver.eventValues).toEventually(equal([ChatRelatedItemsState.visible(listingId: listingId)]))
                        }
                    }

                }
                context("safety tips") {
                    context("userChatSafetyTipsShown is false and there is no message from interlocutor") {
                        beforeEach {
                            keyValueStorage.userChatSafetyTipsShown = false
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               user: user)
                            sut.active = true
                        }
                        it("safety tips show up") {
                            expect(self.safetyTipsShown).toEventually(equal(false))
                        }
                    }
                    context("userChatSafetyTipsShown is true and there is no message from interlocutor") {
                        beforeEach {
                            keyValueStorage.userChatSafetyTipsShown = true
                                chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false)
                                buildChatViewModel(myUser: mockMyUser,
                                                   chatMessages: chatMessages,
                                                   product: productResult,
                                                   chatConversation: chatConversation,
                                                   user: user)
                                sut.active = true
                        }
                        it("safety tips show up") {
                            expect(self.safetyTipsShown).toEventually(equal(false))
                        }
                    }
                    context("userChatSafetyTipsShown is false and there is message from interlocutor") {
                        beforeEach {
                            keyValueStorage.userChatSafetyTipsShown = false
                            chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 10, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 10)
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               user: user)
                            sut.active = true
                        }
                        it("safety tips show up") {
                            expect(self.safetyTipsShown).toEventually(equal(true))
                        }
                    }

                }
            }
            
            describe("send message") {
                describe("new conversation") {
                    describe ("with a regular user") {
                        beforeEach {
                            featureFlags.allowCallsForProfessionals = .control
                            mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                            chatMessages = []
                            productResult = self.makeMockProduct(with: .approved)
                            chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false)
                            user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                            user.type = .user
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               user: user)
                            sut.active = true
                        }
                        context("quick answer") {
                            beforeEach {
                                sut.send(quickAnswer: .meetUp)
                                expect(tracker.trackedEvents.count).toEventually(equal(3))
                            }
                            it("adds interlocutor introduction and one element on messages") {
                                expect(messages.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.text, sut.userInfoMessage!.value]
                            }
                            it("tracks sent first message + message sent") {
                                expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "product-detail-ask-question", "user-sent-message"]
                            }
                            it("should not clean textField") {

                                expect(self.textFieldCleaned) == false
                            }
                        }
                        context("custom text") {
                            beforeEach {
                                sut.send(text: "text")
                                expect(tracker.trackedEvents.count).toEventually(equal(3))
                            }
                            it("adds interlocutor introduction and one element on messages") {
                                expect(messages.lastValue?.map{ $0.value }) == ["text", sut.userInfoMessage!.value]
                            }
                            it("tracks sent first message + message sent") {
                                expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "product-detail-ask-question", "user-sent-message"]
                            }
                            it("should clean textField") {
                                expect(self.textFieldCleaned) == true
                            }
                        }
                        context("sticker") {
                            var sticker: MockSticker!
                            beforeEach {
                                sticker = MockSticker.makeMock()
                                sut.send(sticker: sticker)
                                expect(tracker.trackedEvents.count).toEventually(equal(3))
                            }
                            it("adds interlocutor introduction and one element on messages") {
                                expect(messages.lastValue?.map{ $0.value }) == [sticker.name, sut.userInfoMessage!.value]
                            }
                            it("tracks sent first message + message sent") {
                                expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "product-detail-ask-question", "user-sent-message"]
                            }
                            it("should clean textField") {
                                expect(self.textFieldCleaned) == false
                            }
                        }
                    }
                    describe ("with a professional user") {
                        context ("allowCallsForProfessionals ABTest active") {
                            beforeEach {
                                featureFlags.allowCallsForProfessionals = .control
                                mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                                chatMessages = []
                                productResult = self.makeMockProduct(with: .approved)
                                chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                                chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false)
                                user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                                user.type = .pro
                                user.phone = "666-666-666"
                                buildChatViewModel(myUser: mockMyUser,
                                                   chatMessages: chatMessages,
                                                   product: productResult,
                                                   chatConversation: chatConversation,
                                                   user: user)
                                sut.active = true
                            }
                            context("send phone") {
                                beforeEach {
                                    sut.send(phone: "123-456-789")
                                    expect(tracker.trackedEvents.count).toEventually(equal(3))
                                }
                                it("adds interlocutor introduction, the user message and the automatic messages") {
                                    expect(messages.lastValue?.map{ $0.value }) == [LGLocalizedString.professionalDealerAskPhoneThanksPhoneCellMessage,
                                                                                    LGLocalizedString.professionalDealerAskPhoneAddPhoneCellMessage,
                                                                                    LGLocalizedString.professionalDealerAskPhoneChatMessage("123-456-789"),
                                                                                    sut.userInfoMessage!.value]
                                }
                                it("tracks sent first message + message sent") {
                                    expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "product-detail-ask-question", "user-sent-message"]
                                }
                            }
                            context("send regular text") {
                                beforeEach {
                                    sut.send(text: "hello")
                                    expect(tracker.trackedEvents.count).toEventually(equal(3))
                                }
                                it("adds interlocutor introduction, the user message and the automatic messages") {
                                    expect(messages.lastValue?.map{ $0.value }) == [LGLocalizedString.professionalDealerAskPhoneThanksOtherCellMessage,
                                                                                    LGLocalizedString.professionalDealerAskPhoneAddPhoneCellMessage,
                                                                                    "hello",
                                                                                    sut.userInfoMessage!.value]
                                }
                                it("tracks sent first message + message sent") {
                                    expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "product-detail-ask-question", "user-sent-message"]
                                }
                            }
                        }
                        context ("allowCallsForProfessionals ABTest inactive") {
                            beforeEach {
                                featureFlags.allowCallsForProfessionals = .inactive
                                mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                                chatMessages = []
                                productResult = self.makeMockProduct(with: .approved)
                                chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                                chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false)
                                user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                                user.type = .pro
                                user.phone = "666-666-666"
                                buildChatViewModel(myUser: mockMyUser,
                                                   chatMessages: chatMessages,
                                                   product: productResult,
                                                   chatConversation: chatConversation,
                                                   user: user)
                                sut.active = true
                            }
                            context("custom text") {
                                beforeEach {
                                    sut.send(text: "text")
                                    expect(tracker.trackedEvents.count).toEventually(equal(3))
                                }
                                it("adds interlocutor introduction and one element on messages") {
                                    expect(messages.lastValue?.map{ $0.value }) == ["text", sut.userInfoMessage!.value]
                                }
                                it("tracks sent first message + message sent") {
                                    expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "product-detail-ask-question", "user-sent-message"]
                                }
                                it("should clean textField") {
                                    expect(self.textFieldCleaned) == true
                                }
                            }
                        }
                    }
                }
                
                describe("already existing conversation") {
                    beforeEach {
                        mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                        productResult = self.makeMockProduct(with: .approved)
                        chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                        user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                        chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 1, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 1)
                        chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                        buildChatViewModel(myUser: mockMyUser,
                                           chatMessages: chatMessages,
                                           product: productResult,
                                           chatConversation: chatConversation,
                                           user: user)
                        sut.active = true
                    }
                    context("quick answer") {
                        beforeEach {
                            sut.send(quickAnswer: .meetUp)
                        }
                        it("adds one element on messages") {
                            expect(messages.lastValue?.first?.value) == QuickAnswer.meetUp.text
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }).toEventually(equal(["chat-window-open", "user-sent-message"]))
                        }
                        it("should not clean textField") {
                            expect(self.textFieldCleaned) == false
                        }
                    }
                    context("custom text") {
                        beforeEach {
                            sut.send(text: "text")
                        }
                        it("adds one element on messages") {
                            expect(messages.lastValue?.first?.value) == "text"
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }).toEventually(equal(["chat-window-open", "user-sent-message"]))
                        }
                        it("should clean textField") {
                            expect(self.textFieldCleaned) == true
                        }
                    }
                    context("sticker") {
                        var sticker: MockSticker!
                        beforeEach {
                            sticker = MockSticker.makeMock()
                            sut.send(sticker: sticker)
                        }
                        it("adds one element on messages") {
                            expect(messages.lastValue?.first?.value) == sticker.name
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }).toEventually(equal(["chat-window-open", "user-sent-message"]))
                        }
                        it("should clean textField") {
                            expect(self.textFieldCleaned) == false
                        }
                    }
                }
                describe("already existing conversation message returns error") {
                    beforeEach {
                        mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                        productResult = self.makeMockProduct(with: .approved)
                        chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                        user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                        chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 1, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 1)
                        chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                        buildChatViewModel(myUser: mockMyUser,
                                           chatMessages: chatMessages,
                                           product: productResult,
                                           chatConversation: chatConversation,
                                           commandSuccess: false,
                                           user: user)
                        sut.active = true
                    }
                    context("quick answer") {
                        beforeEach {
                            sut.send(quickAnswer: .meetUp)
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent message error") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message-error"]
                        }
                    }
                    context("custom text") {
                        beforeEach {
                            sut.send(text: "text")
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent message error") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message-error"]
                        }
                    }
                    context("sticker") {
                        var sticker: MockSticker!
                        beforeEach {
                            sticker = MockSticker.makeMock()
                            sut.send(sticker: sticker)
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent message error") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message-error"]
                        }
                    }
                }
                describe("ws chat errors are tracked separately") {
                    context("ws network error") {
                        beforeEach {
                            mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                            productResult = self.makeMockProduct(with: .approved)
                            chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                            user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                            chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 1, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 1)
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               commandSuccess: false,
                                               user: user, chatRepoError: .network(wsCode: 6000, onBackground: false))
                            sut.active = true
                            sut.send(text: "text")
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent message error") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message-error"]
                        }
                        it("error Details is 6000") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDetails] as? String) == "6000"
                        }
                        it("error Description is chat Network") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDescription] as? String) == "chat-network"
                        }
                    }
                    context("ws api error") {
                        beforeEach {
                            mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                            productResult = self.makeMockProduct(with: .approved)
                            chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                            user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                            chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 1, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 1)
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               commandSuccess: false,
                                               user: user, chatRepoError: .apiError(httpCode: 500))
                            sut.active = true
                            sut.send(text: "text")
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent message error") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message-error"]
                        }
                        it("error Details is 500") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDetails] as? String) == "500"
                        }
                        it("error Description is chat server") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDescription] as? String) == "chat-server"
                        }
                    }
                    context("ws notAuthenticated error") {
                        beforeEach {
                            mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                            productResult = self.makeMockProduct(with: .approved)
                            chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                            user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                            chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 1, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 1)
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               commandSuccess: false,
                                               user: user, chatRepoError: .notAuthenticated)
                            sut.active = true
                            sut.send(text: "text")
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent message error") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message-error"]
                        }
                        it("error Details is 'user not authenticated'") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDetails] as? String) == "3000 - User not authenticated"
                        }
                        it("error Description is chat internal") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDescription] as? String) == "chat-internal"
                        }
                    }
                    context("ws userNotVerified error") {
                        beforeEach {
                            mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                            productResult = self.makeMockProduct(with: .approved)
                            chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                            user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                            chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 1, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 1)
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               commandSuccess: false,
                                               user: user, chatRepoError: .userNotVerified)
                            sut.active = true
                            sut.send(text: "text")
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent message error") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message-error"]
                        }
                        it("error Details is 'user not verified'") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDetails] as? String) == "6013 - User not verified"
                        }
                        it("error Description is chat internal") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDescription] as? String) == "chat-internal"
                        }
                    }
                    context("ws userBlocked error") {
                        beforeEach {
                            mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                            productResult = self.makeMockProduct(with: .approved)
                            chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                            user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                            chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 1, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 1)
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               commandSuccess: false,
                                               user: user, chatRepoError: .userBlocked)
                            sut.active = true
                            sut.send(text: "text")
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent message error") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message-error"]
                        }
                        it("error Details is 'user blocked'") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDetails] as? String) == "3014 - User blocked"
                        }
                        it("error Description is chat internal") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDescription] as? String) == "chat-internal"
                        }
                    }
                    context("ws internal error") {
                        beforeEach {
                            mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                            productResult = self.makeMockProduct(with: .approved)
                            chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                            user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                            chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 1, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 1)
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               chatConversation: chatConversation,
                                               commandSuccess: false,
                                               user: user, chatRepoError: .internalError(message: "there's some weird bad stuff going on"))
                            sut.active = true
                            sut.send(text: "text")
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("tracks sent message error") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["chat-window-open", "user-sent-message-error"]
                        }
                        it("error Details is the error message") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDetails] as? String) == "there's some weird bad stuff going on"
                        }
                        it("error Description is chat internal") {
                            let msgErrorEvent = tracker.trackedEvents.filter { $0.actualName == "user-sent-message-error" }[0]
                            expect(msgErrorEvent.params?[.errorDescription] as? String) == "chat-internal"
                        }
                    }
                }
            }
        }
    }
}


extension ChatViewModelSpec: ChatViewModelDelegate {
    
    func vmDidFailRetrievingChatMessages() {}
    func vmDidPressReportUser(_ reportUserViewModel: ReportUsersViewModel) {}
    func vmShowUserRating(_ source: RateUserSource, data: RateUserData) {}
    func vmDidRequestSafetyTips() {
        safetyTipsShown = true
    }
    func vmDidSendMessage() {
        textFieldCleaned = true
    }
    func vmDidEndEditing(animated: Bool) {}
    func vmDidBeginEditing() {}
    
    func vmDidRequestShowPrePermissions(_ type: PrePermissionType) {}
    func vmDidNotifyMessage(_ message: String, completion: (() -> ())?) {}
    
    func vmDidPressDirectAnswer(quickAnswer: QuickAnswer) {}

    func vmAskPhoneNumber() {}
}

extension ChatViewModelSpec {
    func makeMockMyUser(with userStatus: UserStatus, isDummy: Bool) -> MockMyUser {
        var myUser = MockMyUser.makeMock()
        myUser.status = userStatus
        myUser.isDummy = isDummy
        return myUser
    }
    
    func makeMockProduct(with status: ListingStatus) -> MockProduct {
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
    
    func makeChatConversation(with interlocutor: ChatInterlocutor, unreadMessageCount: Int, lastMessageSentAt: Date?,
                              amISelling: Bool,
                              listingStatus: ListingStatus? = nil) -> MockChatConversation {
        let listingStatus: ListingStatus = listingStatus ?? .approved
        var chatListing = MockChatListing.makeMock()
        chatListing.status = listingStatus

        var chatConversation = MockChatConversation.makeMock()
        chatConversation.listing = chatListing
        chatConversation.interlocutor = interlocutor
        chatConversation.unreadMessageCount = unreadMessageCount
        chatConversation.lastMessageSentAt = lastMessageSentAt
        chatConversation.amISelling = amISelling
        return chatConversation
    }
    
    func makeUser(with status: UserStatus, isDummy: Bool, userId: String) -> MockUser {
        var user = MockUser.makeMock()
        user.status = status
        user.isDummy = isDummy
        user.objectId = userId
        return user
    }
    
    func makeChatMessages(with myUserId: String, myMessagesNumber: Int, interlocutorId: String, interlocutorNumberMessages: Int) -> [MockChatMessage] {
        var messages: [MockChatMessage] = []
        for _ in 0..<myMessagesNumber {
            var chatMessage = MockChatMessage.makeMock()
            chatMessage.talkerId = myUserId
            messages.append(chatMessage)
        }
        for _ in 0..<interlocutorNumberMessages {
            var chatMessage = MockChatMessage.makeMock()
            chatMessage.talkerId = interlocutorId
            messages.append(chatMessage)
        }
        return messages
    }
}
