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

    override func spec() {

        var sut: NotificationsManager!
        var sessionManager: MockSessionManager!
        var myUserRepository: MockMyUserRepository!
        var chatRepository: MockChatRepository!
        var oldChatRepository: MockOldChatRepository!
        var notificationsRepository: MockNotificationsRepository!
        var keyValueStorage: KeyValueStorage!
        var featureFlags: MockFeatureFlags!

        var disposeBag: DisposeBag!

        var unreadMessagesObserver: TestableObserver<Int?>!
        var favoriteObserver: TestableObserver<Int?>!
        var unreadNotificationsObserver: TestableObserver<Int?>!
        var globalCountObserver: TestableObserver<Int>!
        var marketingNotificationsObserver: TestableObserver<Bool>!
        var loggedInMarketingNotificationsObserver: TestableObserver<Bool>!

        describe("NotificationsManagerSpec") {
            func createNotificationsManager() {
                sut = NotificationsManager(sessionManager: sessionManager, chatRepository: chatRepository,
                                           oldChatRepository: oldChatRepository, notificationsRepository: notificationsRepository,
                                           keyValueStorage: keyValueStorage, featureFlags: featureFlags)

                disposeBag = nil
                disposeBag = DisposeBag()
                sut.unreadMessagesCount.asObservable().bindTo(unreadMessagesObserver).addDisposableTo(disposeBag)
                sut.favoriteCount.asObservable().bindTo(favoriteObserver).addDisposableTo(disposeBag)
                sut.unreadNotificationsCount.asObservable().bindTo(unreadNotificationsObserver).addDisposableTo(disposeBag)
                sut.globalCount.bindTo(globalCountObserver).addDisposableTo(disposeBag)
                sut.marketingNotifications.asObservable().bindTo(marketingNotificationsObserver).addDisposableTo(disposeBag)
                sut.loggedInMktNofitications.asObservable().bindTo(loggedInMarketingNotificationsObserver).addDisposableTo(disposeBag)
            }

            func setMyUser() {
                let myUser = MockMyUser()
                myUser.objectId = String.random(20)
                myUserRepository.myUserVar.value = myUser
            }

            func doLogin() {
                if myUserRepository.myUser == nil {
                    setMyUser()
                }
                sessionManager.loggedIn = true
                sessionManager.sessionEventsPublish.onNext(.login)
            }

            func doLogout() {
                myUserRepository.myUserVar.value = nil
                sessionManager.loggedIn = false
                sessionManager.sessionEventsPublish.onNext(.logout(kickedOut: false))
            }

            func populateCountersResults() {
                oldChatRepository.unreadMessagesResult = Result<Int, RepositoryError>(10)
                let chatUnread = MockChatUnreadMessages(total: 7)
                chatRepository.chatUnreadMessagesResult = ChatUnreadMessagesResult(chatUnread)
                let notifications = MockUnreadNotificationsCounts(sold: 2, like: 2, review: 2, reviewUpdate: 2, buyers: 2, suggested: 2, facebook: 2, total: 14)
                notificationsRepository.notificationsUnreadCountResult = NotificationsUnreadCountResult(notifications)
            }

            beforeEach {
                sessionManager = MockSessionManager()
                chatRepository = MockChatRepository()
                oldChatRepository = MockOldChatRepository()
                notificationsRepository = MockNotificationsRepository()
                myUserRepository = MockMyUserRepository()
                keyValueStorage = KeyValueStorage(storage: MockKeyValueStorage(), myUserRepository: myUserRepository)
                featureFlags = MockFeatureFlags()

                let scheduler = TestScheduler(initialClock: 0)
                scheduler.start()

                unreadMessagesObserver = scheduler.createObserver(Optional<Int>.self)
                favoriteObserver = scheduler.createObserver(Optional<Int>.self)
                unreadNotificationsObserver = scheduler.createObserver(Optional<Int>.self)
                globalCountObserver = scheduler.createObserver(Int.self)
                marketingNotificationsObserver = scheduler.createObserver(Bool.self)
                loggedInMarketingNotificationsObserver = scheduler.createObserver(Bool.self)
            }

            describe("initialisation (setup)") {
                describe("notifications & chat counters") {
                    beforeEach {
                        populateCountersResults()
                        createNotificationsManager()
                    }
                    context("not logged in") {
                        beforeEach {
                            sessionManager.loggedIn = false
                            sut.setup()
                            let _ = self.expectation(description: "Wait for network calls")
                            self.waitForExpectations(timeout: 0.2, handler: nil)
                        }
                        it("unreadMessagesCount just emits a nil value") {
                            XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil)])
                        }
                        it("unreadNotificationsCount just emits a nil value") {
                            XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil)])
                        }
                        it("globalCount is 0") {
                            XCTAssertEqual(globalCountObserver.events, [next(0, 0)])
                        }
                    }
                    context("logged in") {
                        beforeEach {
                            sessionManager.loggedIn = true
                        }
                        context("notificationsEnabled & old chat & review disabled") {
                            beforeEach {
                                featureFlags.notificationsSection = true
                                featureFlags.websocketChat = false
                                featureFlags.userReviews = false
                                sut.setup()
                                let _ = self.expectation(description: "Wait for network calls")
                                self.waitForExpectations(timeout: 0.2, handler: nil)
                            }
                            it("unreadMessagesCount emits a nil and then the 10") {
                                XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 10)])
                            }
                            it("unreadNotificationsCount emits and then the 10") {
                                XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil), next(0, 10)])
                            }
                            it("globalCount is 24") {
                                expect(globalCountObserver.events.last?.value.element!) == 20
                            }
                        }
                        context("notificationsEnabled & new chat & review enabled") {
                            beforeEach {
                                featureFlags.notificationsSection = true
                                featureFlags.websocketChat = true
                                featureFlags.userReviews = true
                                sut.setup()
                                let _ = self.expectation(description: "Wait for network calls")
                                self.waitForExpectations(timeout: 0.2, handler: nil)
                            }
                            it("unreadMessagesCount emits a nil and then the 7") {
                                XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 7)])
                            }
                            it("unreadNotificationsCount emits and then the 14") {
                                XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil), next(0, 14)])
                            }
                            it("globalCount is 21") {
                                expect(globalCountObserver.events.last?.value.element!) == 21
                            }
                        }
                        context("notificationsDisabled & new chat & review enabled") {
                            beforeEach {
                                featureFlags.notificationsSection = false
                                featureFlags.websocketChat = true
                                featureFlags.userReviews = true
                                sut.setup()
                                let _ = self.expectation(description: "Wait for network calls")
                                self.waitForExpectations(timeout: 0.2, handler: nil)
                            }
                            it("unreadMessagesCount emits a nil and then the 7") {
                                XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 7)])
                            }
                            it("unreadNotificationsCount just emits a nil value") {
                                XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil)])
                            }
                            it("globalCount is 7") {
                                expect(globalCountObserver.events.last?.value.element!) == 7
                            }
                        }
                    }
                }
                describe("favorites count") {
                    beforeEach {
                        createNotificationsManager()
                    }
                    context("not logged in") {
                        beforeEach {
                            sut.setup()
                        }
                        it("favoriteCount has an initial nil, and then emits another after setup") {
                            XCTAssertEqual(favoriteObserver.events, [next(0, nil), next(0, nil)])
                        }
                    }
                    context("logged in") {
                        beforeEach {
                            doLogin()
                        }
                        context("nothing stored") {
                            beforeEach {
                                keyValueStorage.productsMarkAsFavorite = nil
                                sut.setup()
                            }
                            it("favoriteCount has an initial nil, and then emits another after setup") {
                                XCTAssertEqual(favoriteObserver.events, [next(0, nil), next(0, nil)])
                            }
                        }
                        context("1 favorite stored") {
                            beforeEach {
                                keyValueStorage.productsMarkAsFavorite = 1
                                sut.setup()
                            }
                            it("favoriteCount emits a nil and then the 1") {
                                XCTAssertEqual(favoriteObserver.events, [next(0, nil), next(0, 1)])
                            }
                        }
                        context("20 favorite stored") {
                            beforeEach {
                                keyValueStorage.productsMarkAsFavorite = 20
                                sut.setup()
                            }
                            it("favoriteCount emits a nil and then the 1") {
                                XCTAssertEqual(favoriteObserver.events, [next(0, nil), next(0, 1)])
                            }
                        }
                    }
                }
                describe("mkt notifications") {
                    context("not logged in") {
                        beforeEach {
                            sessionManager.loggedIn = false
                            createNotificationsManager()
                        }
                        context("no stored value") {
                            beforeEach {
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just false") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                        context("stored true value") {
                            beforeEach {
                                keyValueStorage.userMarketingNotifications = true
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just false") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                        context("stored false value") {
                            beforeEach {
                                keyValueStorage.userMarketingNotifications = false
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just false") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                    }
                    context("logged in") {
                        beforeEach {
                            doLogin()
                        }
                        context("no stored value") {
                            beforeEach {
                                createNotificationsManager()
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just default value true") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, true)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                        context("stored true value") {
                            beforeEach {
                                keyValueStorage.userMarketingNotifications = true
                                createNotificationsManager()
                                sut.setup()
                            }
                            it("enabledMktNotifications emits true") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, true)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                        context("stored false value") {
                            beforeEach {
                                keyValueStorage.userMarketingNotifications = false
                                createNotificationsManager()
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just false") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, false)])
                            }
                        }
                    }
                }
            }
            describe("login event") {
                beforeEach {
                    sessionManager.loggedIn = false
                    populateCountersResults()
                }
                describe("notifications & chat counters") {
                    beforeEach {
                        createNotificationsManager()
                    }
                    context("notificationsEnabled & old chat & review disabled") {
                        beforeEach {
                            featureFlags.notificationsSection = true
                            featureFlags.websocketChat = false
                            featureFlags.userReviews = false
                            sut.setup()
                            doLogin()
                            let _ = self.expectation(description: "Wait for network calls")
                            self.waitForExpectations(timeout: 0.2, handler: nil)
                        }
                        it("unreadMessagesCount emits a nil and then the 10") {
                            XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 10)])
                        }
                        it("unreadNotificationsCount emits and then the 10") {
                            XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil), next(0, 10)])
                        }
                        it("globalCount is 24") {
                            expect(globalCountObserver.events.last?.value.element!) == 20
                        }
                    }
                    context("notificationsEnabled & new chat & review enabled") {
                        beforeEach {
                            featureFlags.notificationsSection = true
                            featureFlags.websocketChat = true
                            featureFlags.userReviews = true
                            sut.setup()
                            doLogin()
                            let _ = self.expectation(description: "Wait for network calls")
                            self.waitForExpectations(timeout: 0.2, handler: nil)
                        }
                        it("unreadMessagesCount emits a nil and then the 7") {
                            XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 7)])
                        }
                        it("unreadNotificationsCount emits and then the 14") {
                            XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil), next(0, 14)])
                        }
                        it("globalCount is 21") {
                            expect(globalCountObserver.events.last?.value.element!) == 21
                        }
                    }
                    context("notificationsDisabled & new chat & review enabled") {
                        beforeEach {
                            featureFlags.notificationsSection = false
                            featureFlags.websocketChat = true
                            featureFlags.userReviews = true
                            sut.setup()
                            doLogin()
                            let _ = self.expectation(description: "Wait for network calls")
                            self.waitForExpectations(timeout: 0.2, handler: nil)
                        }
                        it("unreadMessagesCount emits a nil and then the 7") {
                            XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 7)])
                        }
                        it("unreadNotificationsCount just emits a nil value") {
                            XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil)])
                        }
                        it("globalCount is 7") {
                            expect(globalCountObserver.events.last?.value.element!) == 7
                        }
                    }
                }
                describe("mkt notification") {
                    beforeEach {
                        createNotificationsManager()
                        sut.setup()
                    }
                    context("no stored value") {
                        beforeEach {
                            doLogin()
                        }
                        it("enabledMktNotifications emits false, and then true after login") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false), next(0, true)])
                        }
                        it("loggedInMktNofitications emits true on init, true on setup and then true again after login") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0, true), next(0, true)])
                        }
                    }
                    context("stored true value") {
                        beforeEach {
                            setMyUser()
                            keyValueStorage.userMarketingNotifications = true
                            doLogin()
                        }
                        it("enabledMktNotifications emits false, and then true after login") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false), next(0, true)])
                        }
                        it("loggedInMktNofitications emits true, true on setup and then true again after login") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0, true), next(0, true)])
                        }
                    }
                    context("stored false value") {
                        beforeEach {
                            setMyUser()
                            keyValueStorage.userMarketingNotifications = false
                            doLogin()
                        }
                        it("enabledMktNotifications emits false, and then false again after login") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false), next(0, false)])
                        }
                        it("loggedInMktNofitications emits true on init, true on setup and then false after login") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0,true), next(0, false)])
                        }
                    }
                }
            }
            describe("logout event") {
                beforeEach {
                    doLogin()
                    populateCountersResults()
                }
                describe("notifications & chat counters") {
                    beforeEach {
                        createNotificationsManager()
                    }
                    context("notificationsEnabled & old chat & review disabled") {
                        beforeEach {
                            featureFlags.notificationsSection = true
                            featureFlags.websocketChat = false
                            featureFlags.userReviews = false
                            sut.setup()
                            let _ = self.expectation(description: "Wait for network calls")
                            self.waitForExpectations(timeout: 0.2, handler: nil)
                            doLogout()
                        }
                        it("unreadMessagesCount emits a nil, 10 and 0") {
                            XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 10), next(0, nil)])
                        }
                        it("unreadNotificationsCount emits nil, 10 and 0") {
                            XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil), next(0, 10), next(0, nil)])
                        }
                        it("globalCount is 0") {
                            expect(globalCountObserver.events.last?.value.element!) == 0
                        }
                    }
                    context("notificationsEnabled & new chat & review enabled") {
                        beforeEach {
                            featureFlags.notificationsSection = true
                            featureFlags.websocketChat = true
                            featureFlags.userReviews = true
                            sut.setup()
                            let _ = self.expectation(description: "Wait for network calls")
                            self.waitForExpectations(timeout: 0.2, handler: nil)
                            doLogout()
                        }
                        it("unreadMessagesCount emits a nil, 7 and 0") {
                            XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 7), next(0, nil)])
                        }
                        it("unreadNotificationsCount emits nil, 14 and 0") {
                            XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil), next(0, 14), next(0, nil)])
                        }
                        it("globalCount is 0") {
                            expect(globalCountObserver.events.last?.value.element!) == 0
                        }
                    }
                    context("notificationsDisabled & new chat & review enabled") {
                        beforeEach {
                            featureFlags.notificationsSection = false
                            featureFlags.websocketChat = true
                            featureFlags.userReviews = true
                            sut.setup()
                            let _ = self.expectation(description: "Wait for network calls")
                            self.waitForExpectations(timeout: 0.2, handler: nil)
                            doLogout()
                        }
                        it("unreadMessagesCount emits a nil, 7 and 0") {
                            XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 7), next(0,nil)])
                        }
                        it("unreadNotificationsCount just emits a nil value") {
                            XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil)])
                        }
                        it("globalCount is 0") {
                            expect(globalCountObserver.events.last?.value.element!) == 0
                        }
                    }
                }
                describe("mkt notification") {
                    context("no stored value") {
                        beforeEach {
                            createNotificationsManager()
                            sut.setup()
                            doLogout()
                        }
                        it("enabledMktNotifications emits true") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, true)])
                        }
                        it("loggedInMktNofitications emits true, and then true after logout") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0, true)])
                        }
                    }
                    context("stored true value") {
                        beforeEach {
                            keyValueStorage.userMarketingNotifications = true
                            createNotificationsManager()
                            sut.setup()
                            doLogout()
                        }
                        it("enabledMktNotifications emits true") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, true)])
                        }
                        it("loggedInMktNofitications emits true, and then true again after logout") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0, true)])
                        }
                    }
                    context("stored false value") {
                        beforeEach {
                            keyValueStorage.userMarketingNotifications = false
                            createNotificationsManager()
                            sut.setup()
                            doLogout()
                        }
                        it("enabledMktNotifications emits false") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                        }
                        it("loggedInMktNofitications emits false, and then true after logout") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, false), next(0, true)])
                        }
                    }
                }
            }
        }
    }
}
