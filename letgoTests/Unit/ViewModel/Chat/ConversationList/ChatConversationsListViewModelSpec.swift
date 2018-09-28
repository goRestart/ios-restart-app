//
//  ChatConversationsListViewModelSpec.swift
//  letgoTests
//
//  Created by Nestor on 20/06/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import RxSwift
import RxTest
import Result

final class ChatConversationsListViewModelSpec: QuickSpec {
    
    override func spec() {
        var sut: ChatConversationsListViewModel!
        var chatRepository: MockChatRepository!
        var sessionManager: MockSessionManager!
        var notificationsManager: MockNotificationsManager!
        var featureFlags: MockFeatureFlags!
        var tracker: MockTracker!
        
        var scheduler: TestScheduler!
        var bag: DisposeBag!
        
        describe("ChatConversationsListViewModel") {
            beforeEach {
                chatRepository = MockChatRepository()
                sessionManager = MockSessionManager()
                notificationsManager = MockNotificationsManager()
                featureFlags = MockFeatureFlags()
                tracker = MockTracker()
                sut = ChatConversationsListViewModel(chatRepository: chatRepository,
                                                     sessionManager: sessionManager,
                                                     notificationsManager: notificationsManager,
                                                     featureFlags: featureFlags,
                                                     tracker: tracker)
                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                bag = DisposeBag()
            }
            context("viewState") {
                var conversations: [ChatConversation]!
                var viewStateObserver: TestableObserver<ViewState>!
                beforeEach {
                    viewStateObserver = scheduler.createObserver(ViewState.self)
                    sut.viewState
                        .asObservable()
                        .bind(to: viewStateObserver)
                        .disposed(by: bag)
                    
                }
                context("fetch conversation success with X conversations") {
                    beforeEach {
                        conversations = MockChatConversation.makeMocks(count: 3)
                        chatRepository.indexConversationsResult = Result(value: conversations)
                        
                        sut.active = true
                    }
                    it("forwards viewState events: .loading, .data") {
                        expect(viewStateObserver.eventValues).toEventually(equal([.loading, .data]))
                    }
                    it("has X conversations") {
                        expect(sut.rx_conversations.value.count).toEventually(equal(conversations.count))
                    }
                }
                context("fetch conversation success with empty conversations") {
                    beforeEach {
                        conversations = []
                        chatRepository.indexConversationsResult = Result(value: conversations)
                        
                        sut.active = true
                    }
                    it("forwards viewState events: .loading, .empty") {
                        expect(viewStateObserver.eventValues)
                            .toEventually(equal([ .loading, .empty(sut.emptyViewModel(forFilter: .all))]))
                    }
                    it("has 0 conversations") {
                        expect(sut.rx_conversations.value.count).toEventually(equal(0))
                    }
                }
                context("fetch conversation fails") {
                    var repositoryError: RepositoryError!
                    beforeEach {
                        conversations = []
                        repositoryError = .internalError(message: "")
                        chatRepository.indexConversationsResult = Result(error: repositoryError)
                        
                        sut.active = true
                    }
                    it("forwards viewState events: .loading, .error") {
                        expect(viewStateObserver.eventValues)
                            .toEventually(equal([.loading,
                                                 ViewState.error(sut.emptyViewModel(forError: repositoryError)!)]))
                    }
                    it("has 0 conversations") {
                        expect(sut.rx_conversations.value.count).toEventually(equal(0))
                    }
                }
            }
            context("Logout event") {
                var conversations: [ChatConversation]!
                beforeEach {
                    conversations = MockChatConversation.makeMocks(count: 3)
                    chatRepository.indexConversationsResult = Result(value: conversations)
                    sut.active = true
                    expect(sut.rx_conversations.value.count).toEventually(equal(3))
                }
                context("kicked out false") {
                    beforeEach {
                        sessionManager.sessionEventsPublishSubject.onNext(SessionEvent.logout(kickedOut: false))
                    }
                    it("cleans up the conversations") {
                        expect(sut.rx_conversations.value.count).toEventually(equal(0))
                    }
                    it("resets the view state to loading") {
                        expect(sut.rx_viewState.value).toEventually(equal(.loading))
                    }
                    it("resets the isEditing value") {
                        expect(sut.rx_isEditing.value).toEventually(equal(false))
                    }
                }
                context("kicked out true") {
                    beforeEach {
                        sessionManager.sessionEventsPublishSubject.onNext(SessionEvent.logout(kickedOut: true))
                    }
                    it("cleans up the conversations") {
                        expect(sut.rx_conversations.value.count).toEventually(equal(0))
                    }
                    it("resets the view state to loading") {
                        expect(sut.rx_viewState.value).toEventually(equal(.loading))
                    }
                    it("resets the isEditing value") {
                        expect(sut.rx_isEditing.value).toEventually(equal(false))
                    }
                }
            }
            context("Helpers") {
                context("chat counter") {
                    var counter: Int!
                    context("empty conversations") {
                        beforeEach {
                            counter = sut.unreadCount(for: [])
                        }
                        it("returns a counter of 0") {
                            expect(counter) == 0
                        }
                    }
                    context("one conversations") {
                        beforeEach {
                            var conv1 = MockChatConversation.makeMock()
                            conv1.unreadMessageCount = 1
                            counter = sut.unreadCount(for: [conv1])
                        }
                        it("returns a counter of 1") {
                            expect(counter) == 1
                        }
                    }
                    context("more than one conversations") {
                        beforeEach {
                            var conv1 = MockChatConversation.makeMock()
                            conv1.unreadMessageCount = 1
                            var conv2 = MockChatConversation.makeMock()
                            conv2.unreadMessageCount = 2
                            counter = sut.unreadCount(for: [conv1, conv2])
                        }
                        it("returns a counter of 3") {
                            expect(counter) == 3
                        }
                    }
                }
            }
            context("Trackings") {
                context("mark all conversation as read") {
                    beforeEach {
                        chatRepository.markConversationAsReadResult = Result(value: ())
                        sut.markAllConversationAsRead()
                    }
                    it("tracks markMessagesAsRead event") {
                        expect(tracker.trackedEvents.compactMap { $0.name })
                            .toEventually(equal([.markMessagesAsRead]))
                    }
                }
                context("delete conversation") {
                    var conversation: MockChatConversation!
                    beforeEach {
                        conversation = MockChatConversation.makeMock()
                        chatRepository.archiveCommandResult = Result(value: ())
                        sut.deleteConversation(conversation: conversation)
                    }
                    it("tracks chatDeleteComplete event") {
                        expect(tracker.trackedEvents.compactMap { $0.name })
                            .toEventually(equal([.chatDeleteComplete]))
                    }
                }
                context("request error that ends in ViewState.error") {
                    beforeEach {
                        chatRepository.indexConversationsResult = Result(error: .internalError(message: ""))
                        
                        sut.active = true
                    }
                    it("tracks chatDeleteComplete event") {
                        expect(tracker.trackedEvents.compactMap { $0.name })
                            .toEventually(equal([.emptyStateError]))
                    }
                }
                context("sell start action on empty view screen") {
                    context("filter by all") {
                        beforeEach {
                            sut.emptyViewModel(forFilter: .all).action?()
                        }
                        it("tracks listingSellStart event") {
                            expect(tracker.trackedEvents.compactMap { $0.name })
                                .toEventually(equal([.listingSellStart]))
                        }
                    }
                    context("filter by buying") {
                        beforeEach {
                            sut.emptyViewModel(forFilter: .buying).action?()
                        }
                        it("tracks no event") {
                            expect(tracker.trackedEvents.compactMap { $0.name })
                                .toEventually(equal([]))
                        }
                    }
                    context("filter by selling") {
                        beforeEach {
                            sut.emptyViewModel(forFilter: .selling).action?()
                        }
                        it("tracks listingSellStart event") {
                            expect(tracker.trackedEvents.compactMap { $0.name })
                                .toEventually(equal([.listingSellStart]))
                        }
                    }
                }
            }
        }
    }
}
