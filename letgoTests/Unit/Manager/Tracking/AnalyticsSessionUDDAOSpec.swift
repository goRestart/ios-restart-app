@testable import LetGoGodMode
import LGCoreKit
import Nimble
import Quick

final class AnalyticsSessionUDDAOSpec: QuickSpec {
    override func spec() {
        describe("AnalyticsSessionUDDAO") {
            var keyValueStorage: MockKeyValueStorage!
            var sut: AnalyticsSessionUDDAO!
            beforeEach {
                keyValueStorage = MockKeyValueStorage()
                keyValueStorage.currentUserProperties = UserDefaultsUser()
                sut = AnalyticsSessionUDDAO(keyValueStorage: keyValueStorage)
            }

            describe("retrieve") {
                context("with no previously saved session") {
                    beforeEach {
                        sut = AnalyticsSessionUDDAO(keyValueStorage: keyValueStorage)
                    }

                    it("returns nil") {
                        expect(sut.retrieveSessionData()).to(beNil())
                    }
                }

                context("with previously saved session") {
                    beforeEach {
                        let sessionData = AnalyticsSessionData.make(visitStartDate: Date.makeRandom(),
                                                                    visitEndDate: Date.makeRandom())
                        keyValueStorage.analyticsSessionData = sessionData
                        sut = AnalyticsSessionUDDAO(keyValueStorage: keyValueStorage)
                    }

                    it("returns a session data") {
                        expect(sut.retrieveSessionData()).notTo(beNil())
                    }
                }
            }

            describe("save") {
                beforeEach {
                    let sessionData = AnalyticsSessionData.make(visitStartDate: Date.makeRandom(),
                                                                visitEndDate: Date.makeRandom())
                    sut.save(sessionData: sessionData)
                }

                it("stores a dictionary in user defaults") {
                    expect(keyValueStorage.analyticsSessionData).notTo(beNil())
                }
            }
        }
    }
}
