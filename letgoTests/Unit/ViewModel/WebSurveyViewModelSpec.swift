//
//  WebSurveyViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result


class WebSurveyViewModelSpec: BaseViewModelSpec {

    var calledCloseSurvey = false
    var calledSurveyFinished = false

    override func spec() {

        var sut: WebSurveyViewModel!
        var tracker: MockTracker!
        var myUserRepository: MockMyUserRepository!
        var url: URL!

        describe("WebSurveyViewModelSpec") {
            beforeEach {
                self.calledCloseSurvey = false
                self.calledSurveyFinished = false
                tracker = MockTracker()
                myUserRepository = MockMyUserRepository()
                url = URL(string:"https://letgo1.typeform.com/to/e9Ndb4")
                sut = WebSurveyViewModel(surveyUrl: url, tracker: tracker, myUserRepository: myUserRepository)
                sut.navigator = self
            }
            describe("becomes active") {
                context("logged in") {
                    var myUser: MockMyUser!
                    beforeEach {
                        myUser = MockMyUser.makeMock()
                        myUser.objectId = String.makeRandom()
                        myUserRepository.myUserVar.value = myUser
                        sut.active = true
                    }
                    it("tracks survey start event") {
                        expect(tracker.trackedEvents.last?.actualName) == "survey-start"
                    }
                    it("tracks survey start event with correct userId") {
                        expect(tracker.trackedEvents.last?.params?.stringKeyParams["user-id"] as? String) == myUser.emailOrId
                    }
                    it("tracks survey start event with correct url") {
                        expect(tracker.trackedEvents.last?.params?.stringKeyParams["survey-url"] as? String) == url.absoluteString
                    }
                    it("gives correct url with params") {
                        expect(sut.url.absoluteString) == url.absoluteString+"?os=ios&user="+myUser.emailOrId
                    }
                }
                context("not logged in") {
                    beforeEach {
                        sut.active = true
                    }
                    it("tracks survey start event") {
                        expect(tracker.trackedEvents.last?.actualName) == "survey-start"
                    }
                    it("tracks survey start event with correct userId") {
                        expect(tracker.trackedEvents.last?.params?.stringKeyParams["user-id"] as? String).to(beNil())
                    }
                    it("tracks survey start event with correct url") {
                        expect(tracker.trackedEvents.last?.params?.stringKeyParams["survey-url"] as? String) == url.absoluteString
                    }
                    it("gives correct url with params") {
                        expect(sut.url.absoluteString) == url.absoluteString+"?os=ios"
                    }
                }
            }
            describe("loads any url different from redirect one") {
                var shouldLoad: Bool!
                beforeEach {
                    shouldLoad = sut.shouldLoad(url: URL(string:"https://"+String.makeRandom()+".es"))
                }
                it("should load is true") {
                    expect(shouldLoad) == true
                }
                it("doesn't call finish on navigator") {
                    expect(self.calledSurveyFinished) == false
                }
            }
            describe("close without finishing") {
                beforeEach {
                    sut.active = true
                    tracker.trackedEvents.removeAll()
                    sut.closeButtonPressed()
                }
                it("calls close on navigator") {
                    expect(self.calledCloseSurvey) == true
                }
                it("doesn't track survey-completed") {
                    expect(tracker.trackedEvents.count) == 0
                }
            }
            describe("loads redirect url") {
                var shouldLoad: Bool!
                beforeEach {
                    sut.active = true
                    tracker.trackedEvents.removeAll()
                    shouldLoad = sut.shouldLoad(url: URL(string:"http://www.letgo.com"))
                }
                it("should load is false") {
                    expect(shouldLoad) == false
                }
                it("calls close on navigator") {
                    expect(self.calledSurveyFinished) == true
                }
                it("tracks survey completed event") {
                    expect(tracker.trackedEvents.last?.actualName) == "survey-completed"
                }
                it("tracks survey completed event with correct userId") {
                    expect(tracker.trackedEvents.last?.params?.stringKeyParams["user-id"] as? String).to(beNil())
                }
                it("tracks survey completed event with correct url") {
                    expect(tracker.trackedEvents.last?.params?.stringKeyParams["survey-url"] as? String) == url.absoluteString
                }
            }
        }
    }
}

extension WebSurveyViewModelSpec: WebSurveyNavigator {
    func closeWebSurvey() {
        calledCloseSurvey = true
    }

    func webSurveyFinished() {
        calledSurveyFinished = true
    }
}
