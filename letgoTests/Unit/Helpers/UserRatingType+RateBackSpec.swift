import Foundation

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class UserRatingTypeRateBackSpec: QuickSpec {
    override func spec() {
        var sut: UserRatingType!
        
        describe("rateBackType") {
            context ("when user type is conversation") {
                beforeEach {
                    sut = .conversation
                }
                it ("returns conversation") {
                    expect(sut.rateBackType).to(equal(UserRatingType.conversation))
                }
            }
            context ("when user type is buyer") {
                beforeEach {
                    sut = .buyer
                }
                it ("returns seller") {
                    expect(sut.rateBackType).to(equal(UserRatingType.seller))
                }
            }
            context ("when user type is seller") {
                beforeEach {
                    sut = .seller
                }
                it ("returns buyer") {
                    expect(sut.rateBackType).to(equal(UserRatingType.buyer))
                }
            }
        }
    }
}

