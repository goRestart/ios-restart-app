@testable import LetGoGodMode
import LGCoreKit
import Nimble
import Quick

class LGAnalyticsSessionManagerSpec: QuickSpec {
    override func spec() {
        describe("LGAnalyticsSessionManager") {
            var myUser: MockMyUser!
            var myUserRepository: MockMyUserRepository!
            var dao: AnalyticsSessionDAO!
            var sessionThresholdReachedCompletionCalled: Bool!
            let sessionThreshold: TimeInterval = 0.2
            var sut: LGAnalyticsSessionManager!
            beforeEach {
                myUser = MockMyUser.makeMock()
                myUser.creationDate = Date()
                myUserRepository = MockMyUserRepository()
                myUserRepository.myUserVar.value = myUser
                dao = MockAnalyticsSessionDAO()
                sut = LGAnalyticsSessionManager(minTimeBetweenSessions: 0.1,
                                                sessionThreshold: sessionThreshold,
                                                myUserRepository: myUserRepository,
                                                dao: dao)
                sessionThresholdReachedCompletionCalled = false
                sut.sessionThresholdReachedCompletion = { sessionThresholdReachedCompletionCalled = true }
            }

            describe("start or continue session") {
                context("user registered today") {
                    context("without previous visits") {
                        beforeEach {
                            let visitStartDate = Date.makeRandom()
                            sut.startOrContinueSession(visitStartDate: visitStartDate)
                        }

                        it("calls sessionThresholdReachedCompletion") {
                            expect(sessionThresholdReachedCompletionCalled).toEventually(beTrue())
                        }
                    }

                    context("with a previous visit in the same session") {
                        beforeEach {
                            let firstVisitStartDate = Date.makeRandom()
                            sut.startOrContinueSession(visitStartDate: firstVisitStartDate)
                            let firstVisitEndDate = firstVisitStartDate.addingTimeInterval(Double.makeRandom(min: 0.01,
                                                                                                             max: 0.05))
                            sut.pauseSession(visitEndDate: firstVisitEndDate)
                            let secondVisitStartDate = firstVisitEndDate.addingTimeInterval(Double.makeRandom(min: 0.01,
                                                                                                              max: 0.05))
                            sut.startOrContinueSession(visitStartDate: secondVisitStartDate)
                        }

                        it("calls sessionThresholdReachedCompletion") {
                            expect(sessionThresholdReachedCompletionCalled).toEventually(beTrue())
                        }
                    }

                    context("with a previous session") {
                        beforeEach {
                            let firstVisitStartDate = Date.makeRandom()
                            let firstVisitEndDate = firstVisitStartDate.addingTimeInterval(sessionThreshold + 0.1)
                            let sessionData = AnalyticsSessionData.make(visitStartDate: firstVisitStartDate,
                                                                        visitEndDate: firstVisitEndDate)
                            dao.save(sessionData: sessionData)

                            let secondVisitStartDate = firstVisitEndDate.addingTimeInterval(Double.makeRandom(min: 0.01,
                                                                                                              max: 0.05))
                            sut.startOrContinueSession(visitStartDate: secondVisitStartDate)
                        }

                        it("does not call sessionThresholdReachedCompletion") {
                            let waitTime = sessionThreshold + 0.1
                            waitUntil { done in delay(waitTime, completion: done) }
                            expect(sessionThresholdReachedCompletionCalled).to(beFalse())
                        }
                    }
                }

                context("user registered more than a week ago") {
                    beforeEach {
                        myUser.creationDate = Date().addingTimeInterval(TimeInterval.make(days: -8))
                        myUserRepository.myUserVar.value = myUser

                        let visitStartDate = Date.makeRandom()
                        sut.startOrContinueSession(visitStartDate: visitStartDate)
                    }

                    it("does not call sessionThresholdReachedCompletion") {
                        let waitTime = sessionThreshold + 0.1
                        waitUntil { done in delay(waitTime, completion: done) }
                        expect(sessionThresholdReachedCompletionCalled).to(beFalse())
                    }
                }

                context("user did not register") {
                    beforeEach {
                        myUserRepository.myUserVar.value = nil
                    }

                    it("does not call sessionThresholdReachedCompletion") {
                        let waitTime = sessionThreshold + 0.1
                        waitUntil { done in delay(waitTime, completion: done) }
                        expect(sessionThresholdReachedCompletionCalled).to(beFalse())
                    }
                }
            }

            describe("pause session") {
                var visitStartDate: Date!
                beforeEach {
                    visitStartDate = Date.makeRandom()
                    sut.startOrContinueSession(visitStartDate: visitStartDate)
                }

                context("before session threshold reached") {
                    var visitEndDate: Date!
                    beforeEach {
                        visitEndDate = visitStartDate.addingTimeInterval(Double.makeRandom(min: 0.01,
                                                                                           max: 0.1))
                        sut.pauseSession(visitEndDate: visitEndDate)
                    }

                    it("does not call sessionThresholdReachedCompletion if sessionThreshold is exceeded") {
                        let waitTime = sessionThreshold + 0.1
                        waitUntil { done in delay(waitTime, completion: done) }
                        expect(sessionThresholdReachedCompletionCalled).to(beFalse())
                    }
                    it("stores the session data") {
                        let sessionData = AnalyticsSessionData.make(visitStartDate: visitStartDate,
                                                                    visitEndDate: visitEndDate)
                        expect(dao.retrieveSessionData()) == sessionData
                    }
                }

                context("after session threshold reached") {
                    var visitEndDate: Date!
                    beforeEach {
                        let waitTime = sessionThreshold + 0.1
                        visitEndDate = visitStartDate.addingTimeInterval(waitTime)

                        waitUntil { done in delay(waitTime, completion: done) }
                        sut.pauseSession(visitEndDate: visitEndDate)
                    }

                    it("calls sessionThresholdReachedCompletion") {
                        expect(sessionThresholdReachedCompletionCalled).to(beTrue())
                    }
                    it("stores the session data") {
                        let sessionData = AnalyticsSessionData.make(visitStartDate: visitStartDate,
                                                                    visitEndDate: visitEndDate)
                        expect(dao.retrieveSessionData()) == sessionData
                    }
                }
            }
        }
    }
}
