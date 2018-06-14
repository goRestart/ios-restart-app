@testable import LetGoGodMode
import Nimble
import Quick

final class AnalyticsSessionDataSpec: QuickSpec {
    override func spec() {
        describe("AnalyticsSessionData") {
            var startDate: Date!
            var endDate: Date!
            var sut: AnalyticsSessionData!
            beforeEach {
                startDate = Date.makeRandom()
                endDate = startDate.addingTimeInterval(Double.makeRandom(min: 1, max: 10))
                sut = AnalyticsSessionData.make(visitStartDate: startDate,
                                                visitEndDate: endDate)
            }

            describe("make with visit start and end dates") {
                it("saves last visit end date") {
                    expect(sut.lastVisitEndDate) == endDate
                }

                it("sets the length with the visit time diff") {
                    let diff = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
                    expect(sut.length) == diff
                }
            }

            describe("updating with visit start and end dates") {
                var previousLenght: TimeInterval!
                var newStartDate: Date!
                var newEndDate: Date!
                beforeEach {
                    previousLenght = sut.length
                    newStartDate = Date.makeRandom()
                    newEndDate = startDate.addingTimeInterval(Double.makeRandom(min: 1, max: 10))
                    sut = sut.updating(visitStartDate: newStartDate,
                                       visitEndDate: newEndDate)
                }

                it("saves last visit end date") {
                    expect(sut.lastVisitEndDate) == newEndDate
                }

                it("adds visit time diff to the length") {
                    let diff = newEndDate.timeIntervalSince1970 - newStartDate.timeIntervalSince1970
                    expect(sut.length) == previousLenght + diff
                }
            }

            describe("encoding and decoding") {
                var decodedSut: AnalyticsSessionData!
                beforeEach {
                    let encodedSut = sut.encode()
                    decodedSut = AnalyticsSessionData.decode(encodedSut)
                }

                it("generates an equal object") {
                    expect(sut) == decodedSut
                }
            }
        }
    }
}

