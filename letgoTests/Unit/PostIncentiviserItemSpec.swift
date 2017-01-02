//
//  PostIncentiviserItemSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 02/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation


@testable import LetGo
import Quick
import Nimble

class PostIncentiviserItemSpec: QuickSpec {
    override func spec() {
        var sut: [PostIncentiviserItem]!
        var date: NSDate!

        describe("PostIncentiviserItemSpec") {

            beforeEach {
                sut = [.PS4, .TV, .Bike, .Motorcycle, .Dresser, .Car, .KidsClothes, .Furniture, .Toys]
            }

            context("january") {
                beforeEach {
                    date = self.dateWithMonth(1)
                }
                it("Gives values for all items") {
                    var previous = ""
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("february") {
                beforeEach {
                    date = self.dateWithMonth(2)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("march") {
                beforeEach {
                    date = self.dateWithMonth(3)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("april") {
                beforeEach {
                    date = self.dateWithMonth(4)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("may") {
                beforeEach {
                    date = self.dateWithMonth(5)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("june") {
                beforeEach {
                    date = self.dateWithMonth(6)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("july") {
                beforeEach {
                    date = self.dateWithMonth(7)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("august") {
                beforeEach {
                    date = self.dateWithMonth(8)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("september") {
                beforeEach {
                    date = self.dateWithMonth(9)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("october") {
                beforeEach {
                    date = self.dateWithMonth(10)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("november") {
                beforeEach {
                    date = self.dateWithMonth(11)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
            context("december") {
                beforeEach {
                    date = self.dateWithMonth(12)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        $0.searchCount(date)
                    }
                }
            }
        }
    }


    private func dateWithMonth(month: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Month], fromDate: NSDate())
        components.month = month
        return calendar.dateFromComponents(components)!
    }
}


