//
//  RateUserViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 29/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift
import RxTest

class RateUserViewModelSpec: BaseViewModelSpec {
    var delegateReceivedUpdateDescriptionLastValue: String?
    var delegateReceivedUpdateTags: Bool = false
    
    var navigatorReceivedRateUserCancel: Bool = false
    var navigatorReceivedRateUserSkip: Bool = false
    var navigatorReceivedRateUserFinishLastValue: Int?
    
    override func resetViewModelSpec() {
        super.resetViewModelSpec()
        delegateReceivedUpdateDescriptionLastValue = nil
        delegateReceivedUpdateTags = false
        
        navigatorReceivedRateUserCancel = false
        navigatorReceivedRateUserSkip = false
        navigatorReceivedRateUserFinishLastValue = nil
    }
    
    override func spec() {
        describe("RateUserViewModel") {
            var sut: RateUserViewModel!
            
            var data: RateUserData!
            var userRatingRepository: MockUserRatingRepository!
            var tracker: MockTracker!
            
            var isLoadingObserver: TestableObserver<Bool>!
            var stateObserver: TestableObserver<RateUserState>!
            var sendTextObserver: TestableObserver<String?>!
            var sendEnabledObserver: TestableObserver<Bool>!
            var ratingObserver: TestableObserver<Int?>!
            var descriptionObserver: TestableObserver<String?>!
            var descriptionCharLimitObserver: TestableObserver<Int>!
            var disposeBag: DisposeBag!
            
            beforeEach {
                self.resetViewModelSpec()
                
                var user = MockUserListing.makeMock()
                user.name = String.makeRandom()
                var avatar = MockFile.makeMock()
                avatar.fileURL = URL.makeRandom()
                user.avatar = avatar
                data = RateUserData(user: user)
                userRatingRepository = MockUserRatingRepository()
                tracker = MockTracker()
                sut = RateUserViewModel(source: .markAsSold,
                                        data: data,
                                        userRatingRepository: userRatingRepository,
                                        tracker: tracker)
                sut.delegate = self
                sut.navigator = self
                
                let scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                
                isLoadingObserver = scheduler.createObserver(Bool.self)
                stateObserver = scheduler.createObserver(RateUserState.self)
                sendTextObserver = scheduler.createObserver(Optional<String>.self)
                sendEnabledObserver = scheduler.createObserver(Bool.self)
                ratingObserver = scheduler.createObserver(Optional<Int>.self)
                descriptionObserver = scheduler.createObserver(Optional<String>.self)
                descriptionCharLimitObserver = scheduler.createObserver(Int.self)
                disposeBag = DisposeBag()
                
                sut.isLoading.asObservable().bindTo(isLoadingObserver).addDisposableTo(disposeBag)
                sut.state.asObservable().bindTo(stateObserver).addDisposableTo(disposeBag)
                sut.sendText.asObservable().bindTo(sendTextObserver).addDisposableTo(disposeBag)
                sut.sendEnabled.asObservable().bindTo(sendEnabledObserver).addDisposableTo(disposeBag)
                sut.rating.asObservable().bindTo(ratingObserver).addDisposableTo(disposeBag)
                sut.description.asObservable().bindTo(descriptionObserver).addDisposableTo(disposeBag)
                sut.descriptionCharLimit.asObservable().bindTo(descriptionCharLimitObserver).addDisposableTo(disposeBag)
            }
            
            describe("initialization") {
                it("returns data's userAvatar when calling userAvatar") {
                    expect(sut.userAvatar) == data.userAvatar
                }
                it("returns data's userName when calling userName") {
                    expect(sut.userName) == data.userName
                }
                it("is not loading") {
                    expect(sut.isLoading.value) == false
                }
                it("has review positive state") {
                    expect(sut.state.value) == RateUserState.review(positive: true)
                }
                it("has send text") {
                    expect(sut.sendText.value).notTo(beNil())
                }
                it("has send disabled") {
                    expect(sut.sendEnabled.value) == false
                }
                it("has no rating") {
                    expect(sut.rating.value).to(beNil())
                }
                it("has no description") {
                    expect(sut.description.value).to(beNil())
                }
                it("has a 255 description char limit") {
                    expect(sut.descriptionCharLimit.value) == 255
                }
                it("has the positive user rating tags") {
                    let tags = (0..<sut.numberOfTags).flatMap { sut.titleForTagAt(index: $0) }
                    let positiveTags = PositiveUserRatingTag.allValues.flatMap { $0.localizedText }
                    expect(tags) == positiveTags
                }
                it("has no selected tag") {
                    let selectedTags = (0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }
                    expect(selectedTags).to(beEmpty())
                }
                it("tracks a userRatingStart event") {
                    let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                    expect(trackedEventNames) == [EventName.userRatingStart]
                }
            }
            
            describe("become active for the first time") {
                context("user did not have a previous rating and retrieval request succeeds") {
                    beforeEach {
                        userRatingRepository.ratingResult = UserRatingResult(error: .notFound)
                        
                        sut.didBecomeActive(true)
                        
                        let _ = self.expectation(description: "wait for network calls")
                        self.waitForExpectations(timeout: 0.2, handler: nil)
                    }
                    
                    it("isLoading emits: false, true, false") {
                         XCTAssertEqual(isLoadingObserver.events, [next(0, false), next(0, true), next(0, false)])
                    }
                }
                
                context("user had a previous rating and retrieval request succeeds") {
                    var userRating: MockUserRating!
                    beforeEach {
                        userRating = MockUserRating.makeMock()
                    }
                    
                    context("comment has tags") {
                        beforeEach {
                            let tag = PositiveUserRatingTag.allValues[0]
                            userRating.comment = String.make(tagsString: [tag.localizedText],
                                                             comment: "Comment")
                            userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                            
                            sut.didBecomeActive(true)
                            
                            let _ = self.expectation(description: "wait for network calls")
                            self.waitForExpectations(timeout: 0.2, handler: nil)
                        }
                        
                        it("isLoading emits: false, true, false") {
                            XCTAssertEqual(isLoadingObserver.events, [next(0, false), next(0, true), next(0, false)])
                        }
                        it("sendEnabled emits: true, false, true") {
                            XCTAssertEqual(isLoadingObserver.events, [next(0, false), next(0, true), next(0, false)])
                        }
                        it("rating emits: nil, number") {
                            XCTAssertEqual(ratingObserver.events, [next(0, nil), next(0, userRating.value)])
                        }
                        it("calls delegate to update description") {
                            expect(self.delegateReceivedUpdateDescriptionLastValue) == "Comment"
                        }
                        it("description emits: nil, string") {
                            XCTAssertEqual(descriptionObserver.events, [next(0, nil), next(0, "Comment")])
                        }
                        it("calls delegate to update tags") {
                            expect(self.delegateReceivedUpdateTags) == true
                        }
                        it("has a selected tag") {
                            let selectedTags = (0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }
                            expect(selectedTags) == [0]
                        }
                    }
                    
                    context("comments has no tags") {
                        beforeEach {
                            userRating.comment = "Comment"
                            userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                            
                            sut.didBecomeActive(true)
                            
                            let _ = self.expectation(description: "wait for network calls")
                            self.waitForExpectations(timeout: 0.2, handler: nil)
                        }
                        
                        it("isLoading emits: false, true, false") {
                            XCTAssertEqual(isLoadingObserver.events, [next(0, false), next(0, true), next(0, false)])
                        }
                        it("sendEnabled emits: true, false, true") {
                            XCTAssertEqual(isLoadingObserver.events, [next(0, false), next(0, true), next(0, false)])
                        }
                        it("rating emits: nil, number") {
                            XCTAssertEqual(ratingObserver.events, [next(0, nil), next(0, userRating.value)])
                        }
                        it("calls delegate to update description") {
                            expect(self.delegateReceivedUpdateDescriptionLastValue) == userRating.comment
                        }
                        it("description emits: nil, string") {
                            XCTAssertEqual(descriptionObserver.events, [next(0, nil), next(0, userRating.comment)])
                        }
                        it("calls delegate to update tags") {
                            expect(self.delegateReceivedUpdateTags) == true
                        }
                        it("has no selected tag") {
                            let selectedTags = (0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }
                            expect(selectedTags).to(beEmpty())
                        }
                    }
                }
                
                context("user rating retrieval request fails") {
                    beforeEach {
                        userRatingRepository.ratingResult = UserRatingResult(error: .serverError(code: 500))
                        
                        sut.didBecomeActive(true)
                        
                        let _ = self.expectation(description: "wait for network calls")
                        self.waitForExpectations(timeout: 0.2, handler: nil)
                    }
                    
                    it("isLoading emits: false, true, false") {
                        XCTAssertEqual(isLoadingObserver.events, [next(0, false), next(0, true), next(0, false)])
                    }
                    it("sendEnabled emits: true, false, true") {
                        XCTAssertEqual(isLoadingObserver.events, [next(0, false), next(0, true), next(0, false)])
                    }
                    it("rating emits: nil") {
                        XCTAssertEqual(ratingObserver.events, [next(0, nil)])
                    }
                    it("does not call delegate to update description") {
                        expect(self.delegateReceivedUpdateDescriptionLastValue).to(beNil())
                    }
                    it("description emits: nil") {
                        XCTAssertEqual(descriptionObserver.events, [next(0, nil)])
                    }
                    it("calls delegate to update tags") {
                        expect(self.delegateReceivedUpdateTags) == false
                    }
                    it("has no selected tag") {
                        let selectedTags = (0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }
                        expect(selectedTags).to(beEmpty())
                    }
                }
            }
            
            describe("become active for the next times") {
                beforeEach {
                    sut.didBecomeActive(false)
                    
                    let _ = self.expectation(description: "wait for network calls")
                    self.waitForExpectations(timeout: 0.2, handler: nil)
                }
                
                it("does not load again") {
                    XCTAssertEqual(isLoadingObserver.events, [next(0, false)])
                }
            }
            
            describe("closeButtonPressed") {
                beforeEach {
                    sut.closeButtonPressed()
                }
                
                it("calls rate user cancel in navigator") {
                    expect(self.navigatorReceivedRateUserCancel) == true
                }
            }
            
            describe("skipButtonPressed") {
                beforeEach {
                    sut.skipButtonPressed()
                }
                
                it("calls rate user skip in navigator") {
                    expect(self.navigatorReceivedRateUserSkip) == true
                }
            }
            
            describe("ratingStarPressed") {
                context("negative rating") {
                    beforeEach {
                        sut.ratingStarPressed(1)
                    }
                    
                    it("rating emits: nil, 1") {
                        XCTAssertEqual(ratingObserver.events, [next(0, nil), next(0, 1)])
                    }
                    
                    it("state emits: .review(positive: true), .review(positive: false)") {
                        XCTAssertEqual(stateObserver.events, [next(0, .review(positive: true)), next(0, .review(positive: false))])
                    }
                    
                    it("sendEnabled emits: false, false") {
                        XCTAssertEqual(sendEnabledObserver.events, [next(0, false), next(0, false)])
                    }
                }
                
                context("positive rating") {
                    beforeEach {
                        sut.ratingStarPressed(5)
                    }
                    
                    it("rating emits: nil, 5") {
                        XCTAssertEqual(ratingObserver.events, [next(0, nil), next(0, 5)])
                    }
                    
                    it("state emits: .review(positive: true)") {
                        XCTAssertEqual(stateObserver.events, [next(0, .review(positive: true))])
                    }
                    
                    it("does not enable send button") {
                        XCTAssertEqual(sendEnabledObserver.events, [next(0, false)])
                    }
                }
                
                context("switch between negative & positive") {
                    beforeEach {
                        sut.ratingStarPressed(1)
                        sut.selectTagAt(index: 0)
                        sut.ratingStarPressed(3)
                    }
                    
                    it("has no selected tag") {
                        let selectedTags = (0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }
                        expect(selectedTags).to(beEmpty())
                    }
                }
            }
            
            context("review state") {
                context("rating not selected and tags not selected") {
                    it("does not enable send button") {
                        XCTAssertEqual(sendEnabledObserver.events, [next(0, false)])
                    }
                }
                
                context("rating selected and tags not selected") {
                    beforeEach {
                        sut.ratingStarPressed(3)
                    }
                    
                    it("does not enable send button") {
                        XCTAssertEqual(sendEnabledObserver.events, [next(0, false)])
                    }
                }
                
                context("rating not selected and tags selected") {
                    beforeEach {
                        sut.selectTagAt(index: 0)
                    }
                    
                    it("does not enable send button") {
                        XCTAssertEqual(sendEnabledObserver.events, [next(0, false), next(0, false)])
                    }
                }
                
                context("rating selected and tags selected") {
                    beforeEach {
                        sut.ratingStarPressed(3)
                        sut.selectTagAt(index: 0)
                    }
                    
                    it("enables send button") {
                        XCTAssertEqual(sendEnabledObserver.events, [next(0, false), next(0, true)])
                    }
                    
                    describe("sendButtonPressed") {
                        context("create/update request succeeds") {
                            beforeEach {
                                let userRating = MockUserRating.makeMock()
                                userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                                sut.sendButtonPressed()
                                
                                let _ = self.expectation(description: "wait for network calls")
                                self.waitForExpectations(timeout: 0.2, handler: nil)
                            }

                            it("sets the state to comment mode") {
                                XCTAssertEqual(stateObserver.events, [next(0, .review(positive: true)), next(0, .comment)])
                            }
                            
                            it("tracks a userRatingComplete event") {
                                let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                                expect(trackedEventNames) == [EventName.userRatingStart, EventName.userRatingComplete]
                            }
                        }
                        
                        context("create/update request fails") {
                            beforeEach {
                                userRatingRepository.ratingResult = UserRatingResult(error: .serverError(code: 500))
                                sut.sendButtonPressed()
                            }
                            
                            it("calls delegate to show an auto fading message") {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(beTrue())
                            }
                        }
                    }
                }
            }
            
            context("comment state") {
                beforeEach {
                    sut.ratingStarPressed(3)
                    sut.selectTagAt(index: 0)
                    let userRating = MockUserRating.makeMock()
                    userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                    sut.sendButtonPressed()
                    
                    let _ = self.expectation(description: "wait for network calls")
                    self.waitForExpectations(timeout: 0.2, handler: nil)
                }
                
                describe("leave comment empty") {
                    it("disables send button") {
                        expect(sut.sendEnabled.value) == false
                    }
                }
                
                describe("type a comment") {
                    beforeEach {
                        sut.description.value = "comment"
                    }
                    
                    it("enables send button") {
                        expect(sut.sendEnabled.value) == true
                    }
                    
                    describe("sendButtonPressed") {
                        context("create/update request succeeds") {
                            beforeEach {
                                let userRating = MockUserRating.makeMock()
                                userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                                sut.sendButtonPressed()
                                
                                let _ = self.expectation(description: "wait for network calls")
                                self.waitForExpectations(timeout: 0.2, handler: nil)
                            }
                            
                            it("calls rate user finish in navigator") {
                                expect(self.navigatorReceivedRateUserFinishLastValue).notTo(beNil())
                            }
                            
                            it("tracks a userRatingComplete event") {
                                let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                                expect(trackedEventNames) == [EventName.userRatingStart, EventName.userRatingComplete, EventName.userRatingComplete]
                            }
                        }
                        
                        context("create/update request fails") {
                            beforeEach {
                                userRatingRepository.ratingResult = UserRatingResult(error: .serverError(code: 500))
                                sut.sendButtonPressed()
                            }
                            
                            it("calls delegate to show an auto fading message") {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(beTrue())
                            }
                        }
                    }
                }
            }
        }
    }
}

extension RateUserViewModelSpec: RateUserNavigator {
    func rateUserCancel() {
        navigatorReceivedRateUserCancel = true
    }
    
    func rateUserSkip() {
        navigatorReceivedRateUserSkip = true
    }
    
    func rateUserFinish(withRating rating: Int) {
        navigatorReceivedRateUserFinishLastValue = rating
    }
}

extension RateUserViewModelSpec: RateUserViewModelDelegate {
    func vmUpdateDescription(_ description: String?) {
        delegateReceivedUpdateDescriptionLastValue = description
    }
    
    func vmUpdateTags() {
        delegateReceivedUpdateTags = true
    }
}
