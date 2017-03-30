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
    
    // Control vars
    var relatedProductsShown: Bool = false
    
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
        
        // Vars to modify on tests:
        var mockMyUser: MockMyUser!
        var chatMessages: [MockChatMessage]!
        var productResult: MockProduct!
        var chatInterlocutor: MockChatInterlocutor!
        var user: MockUser!
        var chatConversation: MockChatConversation!
        
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
                productRepository.indexResult = ProductsResult(value: MockProduct.makeMocks(count: 4)) // related products
                
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
                
                sut.delegate = self
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
                                               interlocutor: chatInterlocutor,
                                               chatConversation: chatConversation,
                                               user: user)
                            sut.active = true
                        }
                        it ("does not have related products") {
                            expect(sut.relatedProducts.count).toEventually(equal(0))
                        }
                        it("does not show related products over the keyboard") {
                            expect(self.relatedProductsShown).toEventually(equal(false))
                        }
                    }
                    context("being a buyer") {
                        beforeEach {
                            chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false)
                            buildChatViewModel(myUser: mockMyUser,
                                               chatMessages: chatMessages,
                                               product: productResult,
                                               interlocutor: chatInterlocutor,
                                               chatConversation: chatConversation,
                                               user: user)
                            sut.active = true
                        }
                        it ("has related products") {
                            expect(sut.relatedProducts.count).toEventually(equal(4))
                        }
                        fit("shows related products over the keyboard") {
                            expect(self.relatedProductsShown).toEventually(equal(true))
                        }
                    }
                }
            }
            
            describe("Review button") {
                beforeEach {
                    mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                    productResult = self.makeMockProduct(with: .approved)
                    chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                    user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                    
                    
                }
                context("there is less than two message for each user") {
                    beforeEach {
                        chatMessages = []
                        chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: true)
                        buildChatViewModel(myUser: mockMyUser,
                                           chatMessages: chatMessages,
                                           product: productResult,
                                           interlocutor: chatInterlocutor,
                                           chatConversation: chatConversation,
                                           user: user)
                        sut.active = true
                    }
                    it("does not show review button") {
                        expect(sut.shouldShowReviewButton.value) == false
                    }
                }
                context("interlocutor has more than 2 messages.") {
                    beforeEach {
                        chatMessages = self.makeChatMessages(with: mockMyUser.objectId!, myMessagesNumber: 10, interlocutorId: chatInterlocutor.objectId!, interlocutorNumberMessages: 10)
                        chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 10, lastMessageSentAt: Date(), amISelling: true)
                        buildChatViewModel(myUser: mockMyUser,
                                           chatMessages: chatMessages,
                                           product: productResult,
                                           interlocutor: chatInterlocutor,
                                           chatConversation: chatConversation,
                                           user: user)
                        sut.active = true
                    }
                    it("show review button") {
                        expect(sut.shouldShowReviewButton.value).toEventually(equal(true), timeout: 10)
                    }
                    context("show tooltip review button") {
                        context("first time on the screen") {
                            beforeEach {
                                keyValueStorage[.userRatingTooltipAlreadyShown] = false
                                buildChatViewModel(myUser: mockMyUser,
                                                   chatMessages: chatMessages,
                                                   product: productResult,
                                                   interlocutor: chatInterlocutor,
                                                   chatConversation: chatConversation,
                                                   user: user)
                                sut.active = true
                            }
                            it("show rating tooltip") {
                                expect(sut.userReviewTooltipVisible.value).toEventually(equal(true))
                            }
                        }
                        context("no first time with review button") {
                            beforeEach {
                                keyValueStorage[.userRatingTooltipAlreadyShown] = true
                                buildChatViewModel(myUser: mockMyUser,
                                                   chatMessages: chatMessages,
                                                   product: productResult,
                                                   interlocutor: chatInterlocutor,
                                                   chatConversation: chatConversation,
                                                   user: user)
                                sut.active = true
                            }
                            it("show rating tooltip") {
                                expect(sut.userReviewTooltipVisible.value).toEventually(equal(false))
                            }
                        }
                    }
                }
            }
            
            describe("send message") {
                describe("new conversation") {
                    beforeEach {
                        mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                        chatMessages = []
                        productResult = self.makeMockProduct(with: .approved)
                        chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                        chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: false)
                        user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                        
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
                        mockMyUser = self.makeMockMyUser(with: .active, isDummy: false)
                        chatMessages = [MockChatMessage.makeMock()]
                        productResult = self.makeMockProduct(with: .approved)
                        chatInterlocutor = self.makeChatInterlocutor(with: .active, isMuted: false, isBanned: false, hasMutedYou: false)
                        chatConversation = self.makeChatConversation(with: chatInterlocutor, unreadMessageCount: 0, lastMessageSentAt: Date(), amISelling: false)
                        user = self.makeUser(with: .active, isDummy: false, userId: mockMyUser.objectId!)
                        
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
                    context("sticker") {
                        beforeEach {
                            sut.send(sticker: MockSticker.makeMock())
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


extension ChatViewModelSpec: ChatViewModelDelegate {
    func vmShowRelatedProducts(_ productId: String?) {
        print("💩💩💩💩💩💩")
        relatedProductsShown = (productId != nil) ? true : false
    }
    
    func vmDidFailRetrievingChatMessages() {
        print("💩💩💩💩💩💩 💩vmDidFailRetrievingChatMessages")
    }
    
    func vmShowReportUser(_ reportUserViewModel: ReportUsersViewModel) {
        print("💩💩💩💩💩💩💩 vmShowReportUser")
    }
    func vmShowUserRating(_ source: RateUserSource, data: RateUserData) {
        print("💩💩💩💩💩💩💩 vmShowUserRating")
    }
    
    func vmShowSafetyTips() {
        print("💩💩💩💩💩💩 vmShowSafetyTips")
    }
    
    func vmClearText() {
        print("💩💩💩💩💩 vmClearText")
    }
    func vmHideKeyboard(_ animated: Bool) {
        print("💩💩💩💩💩 vmHideKeyboard")
    }
    func vmShowKeyboard() {
        print("💩💩💩💩💩 vmShowKeyboard")
    }
    
    func vmAskForRating() {
        print("💩💩💩💩💩 vmAskForRating")
    }
    func vmShowPrePermissions(_ type: PrePermissionType) {
        print("💩💩💩vmShowPrePermissions")
    }
    func vmShowMessage(_ message: String, completion: (() -> ())?) {
        print("💩💩💩💩💩💩 vmShowMessage")
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
    
    func makeChatConversation(with interlocutor: ChatInterlocutor, unreadMessageCount: Int, lastMessageSentAt: Date?, amISelling: Bool) -> MockChatConversation {
        var chatConversation = MockChatConversation.makeMock()
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
