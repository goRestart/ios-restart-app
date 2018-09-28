import Foundation
import Quick
import Nimble
@testable import LetGoGodMode

final class PushNotificationScheduleCheckerSpec: QuickSpec {
    override func spec() {
        var sut: PushNotificationScheduleChecker!

        describe("init") {

            context("with hours out of range") {
                beforeEach {
                    sut = PushNotificationScheduleChecker(startingHour: -1, endingHour: 33)
                }

                it("normalises the starting hour") {
                    expect(sut.startingHour).to(equal(0))
                }
                it("normalises the ending hour") {
                    expect(sut.endingHour).to(equal(23))
                }
            }
            
            context("with hours in range") {
                let start = 23
                let end = 1
                beforeEach {
                    sut = PushNotificationScheduleChecker(startingHour: start, endingHour: end)
                }
                
                it("starting hour is the same") {
                    expect(sut.startingHour).to(equal(start))
                }
                it("ending hour is the same") {
                    expect(sut.endingHour).to(equal(end))
                }
            }
        }
        
        describe("mutePushNotification") {
            let start = 23
            let end = 2

            beforeEach {
                sut = PushNotificationScheduleChecker(startingHour: start, endingHour: end)
            }

            context("with hour in defined range") {
                var result: Bool!
                beforeEach {
                    result = sut.mutePushNotification(at: 1)
                }
                
                it("returns to mute the push") {
                    expect(result).to(beTrue())
                }
            }
            
            context("with hour outside the defined range") {
                var result: Bool!
                beforeEach {
                    result = sut.mutePushNotification(at: 5)
                }
                
                it("returns to not mute the push") {
                    expect(result).to(beFalse())
                }
            }
        }
    }
}
