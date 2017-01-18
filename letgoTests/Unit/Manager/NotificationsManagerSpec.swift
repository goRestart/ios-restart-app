//
//  NotificationsManagerSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 17/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxTest
import Result
@testable import LGCoreKit
@testable import LetGo


class NotificationsManagerSpec: QuickSpec {

    // Probar chorro eventos y variable

    var disposeBag: DisposeBag!

    var unreadMessagesValue: TestableObserver<Int?>!
    var favoriteValue: Int?
    var unreadNotificationsValue: Int?
    var globalCountValue: Int!
    var marketingNotificationsValue: Bool!
    var loggedInMarketingNotificationsValue: Bool!

    override func spec() {

        var sut: NotificationsManager!
        var sessionManager: MockSessionManager!
        var chatRepository: MockChatRepository!
        var oldChatRepository: MockOldChatRepository!
        var notificationsRepository: MockNotificationsRepository!
        var keyValueStorage: KeyValueStorage!
        var featureFlags: MockFeatureFlags!

        beforeEach {
            sessionManager = MockSessionManager()
            chatRepository = MockChatRepository()
            oldChatRepository = MockOldChatRepository()
            notificationsRepository = MockNotificationsRepository()
            keyValueStorage = KeyValueStorage(storage: MockKeyValueStorage(), myUserRepository: MockMyUserRepository())
            featureFlags = MockFeatureFlags()

            let scheduler = TestScheduler(initialClock: 0)
            scheduler.start()

            self.unreadMessagesValue = scheduler.createObserver(Optional<Int>.self)
            self.favoriteValue = nil
            self.unreadNotificationsValue = nil
            self.globalCountValue = nil
            self.marketingNotificationsValue = nil
            self.loggedInMarketingNotificationsValue = nil

            sut = NotificationsManager(sessionManager: sessionManager, chatRepository: chatRepository,
                                       oldChatRepository: oldChatRepository, notificationsRepository: notificationsRepository,
                                       keyValueStorage: keyValueStorage, featureFlags: featureFlags)

            self.disposeBag = DisposeBag()
            sut.unreadMessagesCount.asObservable().bindTo(self.unreadMessagesValue).addDisposableTo(self.disposeBag)

            sut.favoriteCount.asObservable().bindNext {
                self.favoriteValue = $0
            }.addDisposableTo(self.disposeBag)

            sut.unreadNotificationsCount.asObservable().bindNext {
                self.unreadNotificationsValue = $0
            }.addDisposableTo(self.disposeBag)

            sut.globalCount.bindNext {
                self.globalCountValue = $0
            }.addDisposableTo(self.disposeBag)

            sut.marketingNotifications.asObservable().bindNext {
                self.marketingNotificationsValue = $0
            }.addDisposableTo(self.disposeBag)

            sut.loggedInMktNofitications.asObservable().bindNext {
                self.loggedInMarketingNotificationsValue = $0
            }.addDisposableTo(self.disposeBag)


        }

        describe("initialisation") {
            beforeEach {
                sut.setup()
            }
            it("doesn't have unreadMessagesCount") {
                expect(self.unreadMessagesValue.events).to(beEmpty())
//                expect(self.unreadMessagesValue).to(beNil())
            }
            it("doesn't have unreadNotificationsCount") {
                expect(self.unreadNotificationsValue).to(beNil())
            }
            it("doesn't have favoriteCount") {
                expect(self.favoriteValue).to(beNil())
            }
            it("globalCount is 0") {
                expect(self.globalCountValue) == 0
            }
            it("marketing notifications is false") {
                expect(self.marketingNotificationsValue) == false
            }
            it("logged in marketing notifications is true") {
                expect(self.loggedInMarketingNotificationsValue) == true
            }
        }
        describe("unread messages count") {
            context("old chat") {
                var unreadMessagesResult: Result<Int, RepositoryError>!
                beforeEach {
                    sessionManager.loggedIn = true
                    featureFlags.websocketChat = false
                    unreadMessagesResult = nil
                    oldChatRepository.unreadMessagesCompletion = { result in
                        unreadMessagesResult = result
                    }
                }
                context("success") {
                    beforeEach {
                        oldChatRepository.unreadMessagesResult = Result<Int, RepositoryError>(10)
                        sut.setup()
                        expect(unreadMessagesResult).toEventuallyNot(beNil())
                    }
                    fit("has 10 unread messages on counter") {
                        expect(self.unreadMessagesValue.events).to(beEmpty())
                    }
                }
                context("failure") {
                    beforeEach {
                        oldChatRepository.unreadMessagesResult = Result<Int, RepositoryError>(error: .internalError(message: ""))
                        sut.setup()
                        expect(unreadMessagesResult).toEventuallyNot(beNil())
                    }
//                    it("counter is nil") {
//                        expect(self.unreadMessagesValue).to(beNil())
//                    }
                }
            }
            context("api gives 6 counts") {

            }
            context("pre setup") {
                it("doesn't have unreadMessagesCount") {
                    expect(self.unreadMessagesValue).to(beNil())
                }
            }
        }
    }
}
