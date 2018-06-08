@testable import LetGoGodMode
import LGCoreKit
import Nimble
import Quick

class AnalyticsSessionUDDAOSpec: QuickSpec {
    override func spec() {
        describe("AnalyticsSessionUDDAO") {
            var userDefaults: UserDefaults!
            var sut: AnalyticsSessionUDDAO!
            beforeEach {
                userDefaults = UserDefaults.standard
                sut = AnalyticsSessionUDDAO(userDefaults: userDefaults)
            }
            afterEach {
                userDefaults.remove(AnalyticsSessionUDDAO.UserDefaultsKey)
            }

            describe("retrieve") {
                context("with no previously saved session") {
                    beforeEach {
                        sut = AnalyticsSessionUDDAO(userDefaults: userDefaults)
                    }

                    it("returns nil") {
                        expect(sut.retrieveSessionData()).to(beNil())
                    }
                }

                context("with previously saved session") {
                    beforeEach {
                        let sessionData = AnalyticsSessionData.make(visitStartDate: Date.makeRandom(),
                                                                    visitEndDate: Date.makeRandom())
                        let dictionary = sessionData.encode()
                        userDefaults.setValue(dictionary, forKey: AnalyticsSessionUDDAO.UserDefaultsKey)
                        sut = AnalyticsSessionUDDAO(userDefaults: userDefaults)
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
                    expect(userDefaults.dictionary(forKey: AnalyticsSessionUDDAO.UserDefaultsKey)).notTo(beNil())
                }
            }
        }
    }
}
