@testable import LetGoGodMode
import Nimble
import Quick

class AnalyticsSessionDataSpec: QuickSpec {
    override func spec() {
        fdescribe("AnalyticsSessionData") {
            var sut: AnalyticsSessionData!
            beforeEach {
                let startDate = Date.makeRandom()
                let endDate = startDate.addingTimeInterval(Double.makeRandom(min: 1, max: 10))
                sut = AnalyticsSessionData.make(visitStartDate: startDate,
                                                visitEndDate: endDate)
            }

            describe("make with visit start and end dates") {
                var startDate: Date!
                var endDate: Date!
                beforeEach {
                    startDate = Date.makeRandom()
                    endDate = startDate.addingTimeInterval(Double.makeRandom(min: 1, max: 10))
                    sut = AnalyticsSessionData.make(visitStartDate: startDate,
                                                    visitEndDate: endDate)
                }

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
                var startDate: Date!
                var endDate: Date!
                beforeEach {
                    previousLenght = sut.length
                    startDate = Date.makeRandom()
                    endDate = startDate.addingTimeInterval(Double.makeRandom(min: 1, max: 10))
                    sut = sut.updating(visitStartDate: startDate,
                                       visitEndDate: startDate)
                }

                it("saves last visit end date") {
                    expect(sut.lastVisitEndDate) == endDate
                }

                it("adds visit time diff to the length") {
                    let diff = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
                    expect(sut.length) == previousLenght + diff
                }
            }
        }
    }
}

