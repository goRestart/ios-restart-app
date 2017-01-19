//
//  Int+LGSpec.swift
//  LetGo
//
//  Created by Dídac on 17/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import Quick
import Nimble

class IntLGSpec: QuickSpec {
    override func spec() {
        var countDownString: String?

        describe("Int + LG methods") {
            context("seconds to countdown format-> 00:00:00 ") {
                context("positive num of seconds") {
                    beforeEach {
                        countDownString = 90.secondsToCountdownFormat()
                    }
                    it ("result should equal 00:01:30") {
                        expect(countDownString) == "00:01:30"
                    }
                }
                context("0 seconds") {
                    beforeEach {
                        countDownString = 0.secondsToCountdownFormat()
                    }
                    it ("result should equal 00:00:00") {
                        expect(countDownString) == "00:00:00"
                    }
                }
                context("negative num of seconds") {
                    beforeEach {
                        countDownString = (-900).secondsToCountdownFormat()
                    }
                    it ("result should be nil") {
                        expect(countDownString).to(beNil())
                    }
                }
            }
        }
    }
}
