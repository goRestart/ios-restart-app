//
//  ChatBaseViewModelSpec.swift
//  letgoTests
//
//  Created by Nestor on 21/06/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import RxSwift
import RxTest

final class ChatBaseViewModelSpec: QuickSpec {
    
    override func spec() {
        var sut: ChatBaseViewModel!
        var reachability: MockReachability!
        
        var scheduler: TestScheduler!
        var bag: DisposeBag!
        
        describe("ChatConversationsListViewModel") {
            beforeEach {
                reachability = MockReachability()
                sut = ChatBaseViewModel(reachability: reachability)
                
                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                bag = DisposeBag()
            }
            context("reachability") {
                var reachabilityObserver: TestableObserver<Bool>!
                beforeEach {
                    reachabilityObserver = scheduler.createObserver(Bool.self)
                    sut.rx_isReachable
                        .asObservable()
                        .bind(to: reachabilityObserver)
                        .disposed(by: bag)
                }
                context("view model becomes active") {
                    context("online") {
                        beforeEach {
                            reachability.isOnline = true
                            sut.active = true
                        }
                        it("emits events: true (default value), true (online)") {
                            expect(reachabilityObserver.eventValues).toEventually(equal([true, true]))
                        }
                    }
                    context("offline") {
                        beforeEach {
                            reachability.isOnline = false
                            sut.active = true
                        }
                        it("emits events: true (default value), false (offline)") {
                            expect(reachabilityObserver.eventValues).toEventually(equal([true, false]))
                        }
                    }
                }
                context("view model becomes active more than once emits the events once") {
                    beforeEach {
                        reachability.isOnline = true
                        sut.active = true
                        sut.active = false
                        sut.active = true
                    }
                    it("emits events: true (default value), true (online)") {
                        expect(reachabilityObserver.eventValues).toEventually(equal([true, true]))
                    }
                }
            }
        }
    }
}
