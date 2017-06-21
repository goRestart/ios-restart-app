//
//  NotificationsViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 13/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result


class NotificationsViewModelSpec: BaseViewModelSpec {
    
    override func spec() {
        describe("NotificationsViewModelSpec") {
            var sut: NotificationsViewModel!
            var tracker: MockTracker!
            
            describe("Index notifications") {
                beforeEach {
                    tracker = MockTracker()
                }
                
                context("finishes successfully") {
                    context("with zero items") {
                        beforeEach {
                            let notificationsRepository = MockNotificationsRepository()
                            notificationsRepository.indexResult = Result<[NotificationModel], RepositoryError>(value: [])
                            sut = NotificationsViewModel(notificationsRepository: notificationsRepository , listingRepository: MockListingRepository(),
                                                         userRepository: MockUserRepository(), myUserRepository: MockMyUserRepository(),
                                                         notificationsManager: MockNotificationsManager(),
                                                         locationManager: MockLocationManager(), tracker: tracker,
                                                         featureFlags: MockFeatureFlags())
                            sut.refresh()
                        }
                        // no notifications from backend
                        it ("notifications data has not any item") {
                         expect(sut.dataCount).toEventually(equal(0))
                        }
                        it("tracks empty-state-error event") {
                            expect(tracker.trackedEvents.flatMap { $0.name })
                                .toEventually(equal([]))
                        }
                    }
                    context("with items") {
                        beforeEach {
                            let notificationsRepository = MockNotificationsRepository()
                            let notification = MockNotificationModel.makeMock()
                            notificationsRepository.indexResult = Result<[NotificationModel], RepositoryError>(value: [notification])
                            sut = NotificationsViewModel(notificationsRepository: notificationsRepository ,
                                                         listingRepository: MockListingRepository(), userRepository: MockUserRepository(),
                                                         myUserRepository: MockMyUserRepository(), notificationsManager: MockNotificationsManager(),
                                                         locationManager: MockLocationManager(), tracker: tracker,
                                                         featureFlags: MockFeatureFlags())
                            sut.refresh()
                        }
                        
                        it("does not fire empty-state-error") {
                            expect(tracker.trackedEvents.flatMap { $0.name })
                                .toEventually(equal([]))
                        }
                    }
                }
                context("fails with an internet connection error") {
                    beforeEach {
                        let notificationsRepository = MockNotificationsRepository()
                        notificationsRepository.indexResult = Result<[NotificationModel], RepositoryError>(error: .network(errorCode: -1,
                                                                                                                           onBackground: false))
                        sut = NotificationsViewModel(notificationsRepository: notificationsRepository,
                                                     listingRepository: MockListingRepository(), userRepository: MockUserRepository(),
                                                     myUserRepository: MockMyUserRepository(), notificationsManager: MockNotificationsManager(),
                                                     locationManager: MockLocationManager(), tracker: tracker,
                                                     featureFlags: MockFeatureFlags())
                        sut.refresh()
                    }
                    
                    it("fires empty-state-error") {
                        expect(tracker.trackedEvents.flatMap { $0.name })
                            .toEventually(equal([.emptyStateError]))
                    }
                    it("fires empty-state-error with .serverError") {
                        expect((tracker.trackedEvents.flatMap { $0.params }.first)?.stringKeyParams["reason"] as? String)
                            .toEventually(equal("no-internet-connection"))
                    }
                }
                context("fails with too many requests errpr") {
                    beforeEach {
                        let notificationsRepository = MockNotificationsRepository()
                        notificationsRepository.indexResult = Result<[NotificationModel], RepositoryError>(error: .tooManyRequests)
                        sut = NotificationsViewModel(notificationsRepository: notificationsRepository,
                                                     listingRepository: MockListingRepository(), userRepository: MockUserRepository(),
                                                     myUserRepository: MockMyUserRepository(), notificationsManager: MockNotificationsManager(),
                                                     locationManager: MockLocationManager(), tracker: tracker,
                                                     featureFlags: MockFeatureFlags())
                        sut.refresh()
                    }
                    
                    it("fires empty-state-error") {
                        expect(tracker.trackedEvents.flatMap { $0.name })
                            .toEventually(equal([.emptyStateError]))
                    }
                    it("fires empty-state-error with .unknown") {
                        expect((tracker.trackedEvents.flatMap { $0.params }.first)?.stringKeyParams["reason"] as? String)
                            .toEventually(equal("unknown"))
                    }
                }
            }
        }
    }
}
