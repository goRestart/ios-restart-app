import Foundation
@testable import LetGoGodMode
import Quick
import Nimble

final class PostIncentiviserItemSpec: QuickSpec {
    override func spec() {
        var sut: [PostIncentiviserItem]!
        var date: Date!

        describe("PostIncentiviserItemSpec") {

            beforeEach {
                sut = [.ps4, .tv, .bike, .motorcycle, .dresser, .car, .kidsClothes, .furniture, .toys]
            }

            context("january") {
                beforeEach {
                    date = self.dateWithMonth(1)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("february") {
                beforeEach {
                    date = self.dateWithMonth(2)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("march") {
                beforeEach {
                    date = self.dateWithMonth(3)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("april") {
                beforeEach {
                    date = self.dateWithMonth(4)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("may") {
                beforeEach {
                    date = self.dateWithMonth(5)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("june") {
                beforeEach {
                    date = self.dateWithMonth(6)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("july") {
                beforeEach {
                    date = self.dateWithMonth(7)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("august") {
                beforeEach {
                    date = self.dateWithMonth(8)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("september") {
                beforeEach {
                    date = self.dateWithMonth(9)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("october") {
                beforeEach {
                    date = self.dateWithMonth(10)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("november") {
                beforeEach {
                    date = self.dateWithMonth(11)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
            context("december") {
                beforeEach {
                    date = self.dateWithMonth(12)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount).notTo(beNil())
                    }
                }
            }
        }
    }


    fileprivate func dateWithMonth(_ month: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([NSCalendar.Unit.month], from: Date())
        components.month = month
        return calendar.date(from: components)!
    }
}


