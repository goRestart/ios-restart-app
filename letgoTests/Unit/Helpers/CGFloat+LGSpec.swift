//
//  CGFloat+LGSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 20/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Quick
import Nimble

class CGFloatLGSpec: QuickSpec {
    override func spec() {
        var sut: CGFloat!

        describe("CGFloat + LG methods") {
            context("roundNearest") {
                describe("4.24 to 0.5") {
                    beforeEach {
                        sut = CGFloat(4.24).roundNearest(0.5)
                    }
                    it("Equals 4") {
                        expect(sut) == 4
                    }
                }
                describe("4.5 to 0.5") {
                    beforeEach {
                        sut = CGFloat(4.5).roundNearest(0.5)
                    }
                    it("Equals 4.5") {
                        expect(sut) == 4.5
                    }
                }
                describe("4.74 to 0.5") {
                    beforeEach {
                        sut = CGFloat(4.74).roundNearest(0.5)
                    }
                    it("Equals 4.5") {
                        expect(sut) == 4.5
                    }
                }
                describe("4.76 to 0.5") {
                    beforeEach {
                        sut = CGFloat(4.76).roundNearest(0.5)
                    }
                    it("Equals 5") {
                        expect(sut) == 5
                    }
                }
                describe("4.24 to 0.1") {
                    beforeEach {
                        sut = CGFloat(4.24).roundNearest(0.1)
                    }
                    it("Equals 4.2") {
                        expect(sut) == 4.2
                    }
                }
                describe("4.25 to 0.1") {
                    beforeEach {
                        sut = CGFloat(4.25).roundNearest(0.1)
                    }
                    it("Equals 4.3") {
                        expect(sut) == 4.3
                    }
                }
            }
            context("percentageTo") {
                context("greater or equal 'percentageTo'") {
                    beforeEach {
                        sut = CGFloat(0.8).percentageTo(0.5)
                    }
                    it("gives 1.0") {
                        expect(sut) == 1.0
                    }
                }
                describe("half the 'percentageTo'") {
                    beforeEach {
                        sut = CGFloat(0.25).percentageTo(0.5)
                    }
                    it("gives 0.5") {
                        expect(sut) == 0.5
                    }
                }
                describe("quarter the 'percentageTo'") {
                    beforeEach {
                        sut = CGFloat(0.125).percentageTo(0.5)
                    }
                    it("gives 0.25") {
                        expect(sut) == 0.25
                    }
                }
            }
            context("percentageBetween") {
                describe("above or equal the maximum") {
                    beforeEach {
                        sut = CGFloat(1.7).percentageBetween(start: 0.5, end: 1.5)
                    }
                    it("Gives 1.0") {
                        expect(sut) == 1
                    }
                }
                describe("below or equal the minimum") {
                    beforeEach {
                        sut = CGFloat(0.4).percentageBetween(start: 0.5, end: 1.5)
                    }
                    it("Gives 0") {
                        expect(sut) == 0
                    }
                }
                describe("in the half of start and end (1.0 to [0.5,1.5])") {
                    beforeEach {
                        sut = CGFloat(1.0).percentageBetween(start: 0.5, end: 1.5)
                    }
                    it("Gives 0.5") {
                        //Rounding is required as floats are not representing exact 'double' numbers.
                        expect(sut.roundNearest(0.00001)) == CGFloat(0.5).roundNearest(0.00001)
                    }
                }
                describe("in the half of start and end (0.4 to [0.2,0.6])") {
                    beforeEach {
                        sut = CGFloat(0.4).percentageBetween(start: 0.2, end: 0.6)
                    }
                    it("Gives 0.5") {
                        //Rounding is required as floats are not representing exact 'double' numbers.
                        expect(sut.roundNearest(0.00001)) == CGFloat(0.5).roundNearest(0.00001)
                    }
                }
            }
        }
    }
}


