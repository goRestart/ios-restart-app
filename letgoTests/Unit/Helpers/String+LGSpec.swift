//
//  String+LGSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 13/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Quick
import Nimble

class StringLGSpec: QuickSpec {
    override func spec() {
        var sut: String!

        describe("String + LG methods") {
            context("hasEmojis") {
                describe("contains unicodes but not emojis") {
                    beforeEach {
                        sut = "abz12309ASDFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦"
                    }
                    it("Doesn't detect any emoji") {
                        expect(sut.hasEmojis()) == false
                    }
                }
                describe("contains unicodes with emojis") {
                    beforeEach {
                        sut = "abz123🇹🇬6️⃣09AS👍DFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦✍🏿"
                    }
                    it("Detects emojis") {
                        expect(sut.hasEmojis()) == true
                    }
                }
            }
            context("stringByRemovingEmoji") {
                var withoutEmojis: String!
                describe("contains unicodes but not emojis") {
                    beforeEach {
                        sut = "abz12309ASDFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦"
                        withoutEmojis = sut.stringByRemovingEmoji()
                    }
                    it("leaves string as it is") {
                        expect(sut) == withoutEmojis
                    }
                }
                describe("contains unicodes with emojis") {
                    beforeEach {
                        sut = "abz123🇹🇬6️⃣09AS👍DFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦✍🏿"
                        withoutEmojis = sut.stringByRemovingEmoji()
                    }
                    it("removes emojis from the string") {
                        expect(withoutEmojis) == "abz12309ASDFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦"
                    }
                }
            }
            context("isEmail") {
                describe("correct email") {
                    beforeEach {
                        sut = "ajan@pitican.com"
                    }
                    it("returns true") {
                        expect(sut.isEmail()) == true
                    }
                }
                describe("wrong email , instead of . ") {
                    beforeEach {
                        sut = "ajan@pitica,com"
                    }
                    it("returns false") {
                        expect(sut.isEmail()) == false
                    }
                }
                describe("wrong email no @ ") {
                    beforeEach {
                        sut = "ajan[at]pitican.com"
                    }
                    it("returns false") {
                        expect(sut.isEmail()) == false
                    }
                }
                describe("wrong email nothing after .") {
                    beforeEach {
                        sut = "ajan@pitican."
                    }
                    it("returns false") {
                        expect(sut.isEmail()) == false
                    }
                }
                describe("wrong email nothing before @") {
                    beforeEach {
                        sut = "@pitican.com"
                    }
                    it("returns false") {
                        expect(sut.isEmail()) == false
                    }
                }
            }
            context("isValidLengthPrice") {
                describe("correct number") {
                    beforeEach {
                        sut = "999,7"
                    }
                    it("returns true") {
                        expect(sut.isValidLengthPrice()) == true
                    }
                }
                describe("not a number") {
                    beforeEach {
                        sut = "holaquetal"
                    }
                    it("returns false") {
                        expect(sut.isValidLengthPrice()) == false
                    }
                }
                describe("too big number") {
                    beforeEach {
                        sut = "1000000000"
                    }
                    it("returns false") {
                        expect(sut.isValidLengthPrice()) == false
                    }
                }
                describe("too much decimals") {
                    beforeEach {
                        sut = "100,888"
                    }
                    it("returns false") {
                        expect(sut.isValidLengthPrice()) == false
                    }
                }
            }
        }
    }
}

