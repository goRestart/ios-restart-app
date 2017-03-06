//
//  BaseChatGroupedListViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 10/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result


class BaseChatGroupedListViewModelSpec: BaseViewModelSpec {
    
    override func spec() {
        describe("BaseChatGroupedListViewModelSpec") {
            var sut: StringChatGroupedListViewModel!
            var tracker: MockTracker!
        
            describe("Index chats") {
                beforeEach {
                    tracker = MockTracker()
                    sut = StringChatGroupedListViewModel(objects: [], tabNavigator: nil, tracker: tracker)
                }
            
                context("finishes successfully") {
                    context("with zero items") {
                        beforeEach {
                            sut.result = Result<[String], RepositoryError>(value: [])
                            sut.emptyStatusViewModel = LGEmptyViewModel(icon: nil, title: "", body: "", buttonTitle: "", action: nil, secondaryButtonTitle: nil, secondaryAction: nil, emptyReason: .emptyResults)
                            sut.retrievePage(1)
                        }
                        it("does not track empty state error because there was not an error") {
                            let eventNames = tracker.trackedEvents.flatMap { $0.name }
                            expect(eventNames) == []
                        }
                    }
                    context("with items") {
                        beforeEach {
                            sut.result = Result<[String], RepositoryError>(value: ["first", "second"])
                            sut.retrievePage(1)
                        }
                        
                        it("does not fire empty-state-error") {
                            let eventNames = tracker.trackedEvents.flatMap { $0.name }
                            expect(eventNames) == []
                        }
                    }
                }
                context("fails with an internet connection error") {
                    beforeEach {
                        sut.result = Result<[String], RepositoryError>(error: .network(errorCode: -1,
                                                                                       onBackground: false))
                        sut.retrievePage(1)
                    }
                    
                    it("fires empty-state-error") {
                        let eventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.emptyStateError]
                    }
                    it("fires empty-state-error with .serverError") {
                        let eventParams = tracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["reason"] as? String) == "no-internet-connection"
                    }
                }
                context("fails with too many requests errpr") {
                    beforeEach {
                        sut.result = Result<[String], RepositoryError>(error: .tooManyRequests)
                        sut.retrievePage(1)
                    }
                    
                    it("fires empty-state-error") {
                        let eventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.emptyStateError]
                    }
                    it("fires empty-state-error with .unknown") {
                        let eventParams = tracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["reason"] as? String) == "unknown"
                    }
                }
            }
        }
    }
}

class StringChatGroupedListViewModel: BaseChatGroupedListViewModel<String> {
    var result: Result<[String], RepositoryError>!
    
    override func index(_ page: Int, completion: ((Result<[String], RepositoryError>) -> ())?) {
        completion?(result)
    }
}
