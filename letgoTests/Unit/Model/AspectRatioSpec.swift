import Quick
import Nimble
@testable import LetGoGodMode

class AspectRatioSpec: QuickSpec {
    
    override func spec() {
        var sut : AspectRatio!
        
        describe("AspectRatio") {
        
            describe("init") {
                context("passing a 1:1 CGSize as a parameter") {
                    let size = CGSize(width: 1, height: 1)
                    beforeEach {
                        sut = AspectRatio(size: size)
                    }
                    it("returns a custom 1:1 AspectRatio") {
                        expect(sut).to(equal(AspectRatio.custom(width: 10, height: 10)))
                    }
                }
            }
            
            describe("ratio") {
                context("having a 1:1 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.custom(width: 1, height: 1)
                    }
                    it("equals 1") {
                        expect(sut.ratio).to(equal(1))
                    }
                }
                context("having a 2:1 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.custom(width: 2, height: 1)
                    }
                    it("equals 2") {
                        expect(sut.ratio).to(equal(2))
                    }
                }
                context("having a 1:2 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.custom(width: 1, height: 2)
                    }
                    it("equals 0.5") {
                        expect(sut.ratio).to(equal(0.5))
                    }
                }
            }
            
            describe("orientation") {
                context("having a 1:1 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.custom(width: 1, height: 1)
                    }
                    it("equals square") {
                        expect(sut.orientation.hashValue).to(equal(AspectRatio.AspectRatioOrientation.square.hashValue))
                    }
                }
                context("having a 2:1 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.custom(width: 2, height: 1)
                    }
                    it("equals landscape") {
                        expect(sut.orientation.hashValue).to(equal(AspectRatio.AspectRatioOrientation.landscape.hashValue))
                    }
                }
                context("having a 1:2 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.custom(width: 1, height: 2)
                    }
                    it("equals portrait") {
                        expect(sut.orientation.hashValue).to(equal(AspectRatio.AspectRatioOrientation.portrait.hashValue))
                    }
                }
            }

            describe("isMore:oriented:than") {
                context("having a 3:1 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.custom(width: 3, height: 1)
                    }
                    it("returns true comparing landscape orientation to 4:3") {
                        expect(sut.isMore(.landscape, than: AspectRatio.w4h3)).to(beTrue())
                    }
                    it("returns false comparing landscape orientation to 4:1") {
                        expect(sut.isMore(.landscape, than: AspectRatio.custom(width: 4, height: 1))).to(beFalse())
                    }
                }
                
                context("having a 1:3 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.custom(width: 1, height: 3)
                    }
                    it("returns true comparing portrait orientation to 9:16") {
                        expect(sut.isMore(.portrait, than: AspectRatio.w9h16)).to(beTrue())
                    }
                    it("returns false comparing portrait orientation 1:4") {
                        expect(sut.isMore(.portrait, than: AspectRatio.custom(width: 1, height: 4))).to(beFalse())
                    }
                }

                context("having a 1:1 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.square
                    }
                    it("returns false comparing landscape orientation to 4:3") {
                        expect(sut.isMore(.landscape, than: AspectRatio.w4h3)).to(beFalse())
                    }
                    it("returns true comparing portrait orientation to 4:3") {
                        expect(sut.isMore(.portrait, than: AspectRatio.w4h3)).to(beTrue())
                    }
                    it("returns false comparing portrait orientation to 9:16") {
                        expect(sut.isMore(.portrait, than: AspectRatio.w9h16)).to(beFalse())
                    }
                    it("returns true comparing landscape orientation to 9:16") {
                        expect(sut.isMore(.landscape, than: AspectRatio.w9h16)).to(beTrue())
                    }
                }
            }
            
            describe("size:setting:in") {
                context("having a 4:3 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.w4h3
                    }
                    it("returns (64, 48) for a height of 48") {
                        expect(sut.size(setting: 48, in: .height)).to(equal(CGSize(width: 64, height: 48)))
                    }
                    it("returns (64, 48) for a width of 64") {
                        expect(sut.size(setting: 64, in: .width)).to(equal(CGSize(width: 64, height: 48)))
                    }
                }
                
                context("having a 9:16 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.w9h16
                    }
                    it("returns (72, 128) for a height of 128") {
                        expect(sut.size(setting: 128, in: .height)).to(equal(CGSize(width: 72, height: 128)))
                    }
                    it("returns (72, 128) for a width of 72") {
                        expect(sut.size(setting: 72, in: .width)).to(equal(CGSize(width: 72, height: 128)))
                    }
                }

                context("having a 1:1 aspect ratio") {
                    beforeEach {
                        sut = AspectRatio.square
                    }
                    it("returns (5, 5) for a height of 5") {
                        expect(sut.size(setting: 5, in: .height)).to(equal(CGSize(width: 5, height: 5)))
                    }
                    it("returns (5, 5) for a width of 5") {
                        expect(sut.size(setting: 5, in: .width)).to(equal(CGSize(width: 5, height: 5)))
                    }
                }
            }
        }
    }
}
