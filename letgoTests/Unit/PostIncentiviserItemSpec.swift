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
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("february") {
                beforeEach {
                    date = self.dateWithMonth(2)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("march") {
                beforeEach {
                    date = self.dateWithMonth(3)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("april") {
                beforeEach {
                    date = self.dateWithMonth(4)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("may") {
                beforeEach {
                    date = self.dateWithMonth(5)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("june") {
                beforeEach {
                    date = self.dateWithMonth(6)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("july") {
                beforeEach {
                    date = self.dateWithMonth(7)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("august") {
                beforeEach {
                    date = self.dateWithMonth(8)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("september") {
                beforeEach {
                    date = self.dateWithMonth(9)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("october") {
                beforeEach {
                    date = self.dateWithMonth(10)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("november") {
                beforeEach {
                    date = self.dateWithMonth(11)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
                    }
                }
            }
            context("december") {
                beforeEach {
                    date = self.dateWithMonth(12)
                }
                it("Gives values for all items") {
                    sut.forEach {
                        expect($0.searchCount(date)).notTo(beNil())
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


