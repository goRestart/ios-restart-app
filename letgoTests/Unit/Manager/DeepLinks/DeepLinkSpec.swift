@testable import LetGoGodMode
import Quick
import Nimble

final class DeepLinkSpec: QuickSpec {
    override func spec() {
        var sut: DeepLinkPriceFlag!
        
        describe("DeepLinkPriceFlag") {
            context("with price flag equals 1") {
                beforeEach {
                    sut = DeepLinkPriceFlag(rawValue: 1)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has free as price flag") {
                    expect(sut.isFree) == true
                }
            }
            context("with price flag equals 0") {
                beforeEach {
                    sut = DeepLinkPriceFlag(rawValue: 0)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has free as price flag") {
                    expect(sut.isFree) == false
                }
            }
            context("with price flag equals 4") {
                beforeEach {
                    sut = DeepLinkPriceFlag(rawValue: 5)
                }
                it("is nil") {
                    expect(sut).to(beNil())
                }
            }
        }
    }
}
